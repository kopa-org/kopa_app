import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kopa/navigation/app_router.dart';
import 'package:kopa/repository/team_dbu_repository.dart';
import 'package:kopa/repository/team_season_repository.dart';
import 'package:kopa/repository/users_repository.dart';
import 'package:kopa/utils/app_analytics.dart';

enum _CalendarImportMode { updateActiveSeason, startNewSeason }

class DbuCalendarImportFlow {
  static Future<String?> run(
    BuildContext context, {
    required int? teamId,
  }) async {
    final mode = await _chooseImportMode(context, teamId);
    if (!context.mounted || mode == null) {
      return null;
    }

    AppAnalytics.logEvent(
      'dbu_webview_opened',
      parameters: {
        'start_new_season': mode == _CalendarImportMode.startNewSeason,
      },
    );
    final result = await context.push<String>(AppRouter.dbuWebview);
    if (!context.mounted || result == null) {
      return null;
    }

    var resultData = _decodeResult(result);
    if (resultData['dbuTeamId'] == null || resultData['dbuPoolId'] == null) {
      resultData = await _resolvePublicFallback(context, resultData);
      if (!context.mounted || resultData.isEmpty) {
        return null;
      }
    }

    if (mode == _CalendarImportMode.startNewSeason) {
      if (!context.mounted) {
        return null;
      }

      if (teamId == null) {
        throw Exception('Du er ikke tilknyttet et hold.');
      }

      final seasonStarted = await _startSeasonWithUnsettledWarning(
        context,
        teamId: teamId,
        startsOn: DateTime.now(),
        name: _seasonName(resultData),
      );
      if (!seasonStarted) {
        return null;
      }
    }

    await UsersRepository.syncDbuMatchProgram(resultData);

    return mode == _CalendarImportMode.startNewSeason
        ? 'Ny sæson er startet, og kampprogrammet er importeret.'
        : 'Kampprogrammet er opdateret.';
  }

  static Future<_CalendarImportMode?> _chooseImportMode(
    BuildContext context,
    int? teamId,
  ) async {
    if (teamId == null) {
      return _CalendarImportMode.updateActiveSeason;
    }

    final seasons = await TeamSeasonRepository.getSeasons(teamId);
    final hasActiveSeason = seasons.any((season) => season.isActive);
    if (!hasActiveSeason || !context.mounted) {
      return _CalendarImportMode.updateActiveSeason;
    }

    final startNewSeason = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Start ny sæson?'),
        content: const Text(
          'Der er allerede en aktiv sæson. Du kan opdatere det nuværende '
          'kampprogram, eller starte en ny sæson før den nye DBU-plan '
          'importeres. Hvis der mangler resultater fra den aktive sæson, '
          'advarer Kopa dig før sæsonen startes.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(null),
            child: const Text('Annuller'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Opdater nuværende'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Start ny sæson'),
          ),
        ],
      ),
    );

    if (startNewSeason == null) {
      return null;
    }

    return startNewSeason
        ? _CalendarImportMode.startNewSeason
        : _CalendarImportMode.updateActiveSeason;
  }

  static Future<bool> _startSeasonWithUnsettledWarning(
    BuildContext context, {
    required int teamId,
    required DateTime startsOn,
    required String name,
  }) async {
    try {
      await TeamSeasonRepository.startSeason(
        teamId: teamId,
        startsOn: startsOn,
        name: name,
      );
      return true;
    } on UnsettledMatchesWarning catch (warning) {
      if (!context.mounted) {
        return false;
      }

      final proceed = await _confirmUnsettledMatches(context, warning);
      if (proceed != true) {
        return false;
      }

      await TeamSeasonRepository.startSeason(
        teamId: teamId,
        startsOn: startsOn,
        name: name,
        allowUnsettledMatches: true,
      );
      return true;
    }
  }

  static Future<bool?> _confirmUnsettledMatches(
    BuildContext context,
    UnsettledMatchesWarning warning,
  ) {
    final count = warning.unsettledMatchesCount;
    final matchLabel = count == 1 ? 'kamp' : 'kampe';

    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Mangler resultater'),
        content: Text(
          'Der mangler resultater på $count $matchLabel i den aktive sæson. '
          'Du kan stadig starte en ny sæson, men de gamle kampe vil være '
          'låst til den afsluttede sæson uden fulde resultater.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Gå tilbage'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Start alligevel'),
          ),
        ],
      ),
    );
  }

  static Map<String, dynamic> _decodeResult(String result) {
    try {
      final decoded = jsonDecode(result);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {}

    return {};
  }

  static Future<Map<String, dynamic>> _resolvePublicFallback(
    BuildContext context,
    Map<String, dynamic> resultData,
  ) async {
    if (resultData['publicFallback'] != true) {
      return {};
    }

    final clubName = resultData['publicClubName']?.toString().trim() ?? '';
    final teamLabel = resultData['publicTeamLabel']?.toString().trim() ?? '';
    final leaderLabel =
        resultData['publicLeaderLabel']?.toString().trim() ?? '';
    if (clubName.isEmpty || teamLabel.isEmpty) {
      return {};
    }

    final resolved = await TeamDbuRepository.resolvePublicTeam(
      clubName: clubName,
      teamLabel: teamLabel,
      leaderLabel: leaderLabel,
    );
    if (!context.mounted) {
      return {};
    }

    final leaderMatches = resolved.teams
        .where((team) => team.leaderMatchScore > 0)
        .toList(growable: false);
    final candidates = leaderMatches.isNotEmpty
        ? leaderMatches
        : resolved.teams
            .where((team) => team.matchScore > 0)
            .toList(growable: false);
    if (candidates.isEmpty) {
      return {};
    }

    final selected = candidates.length == 1
        ? candidates.first
        : await _choosePublicCandidate(context, candidates);
    if (selected == null) {
      return {};
    }

    return {
      ...resultData,
      'dbuTeamId': selected.dbuTeamId,
      'dbuPoolId': selected.dbuPoolId,
      'dbuTeamLabel': selected.seriesName,
      'seriesName': selected.seriesName,
      'poolLabel': selected.poolLabel,
      'publicResolvedFromPlayerFallback': true,
      'publicLeaderNames': selected.leaderNames,
    };
  }

  static Future<DbuPublicClubTeam?> _choosePublicCandidate(
    BuildContext context,
    List<DbuPublicClubTeam> candidates,
  ) {
    return showDialog<DbuPublicClubTeam>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Vælg DBU-hold'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: candidates.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final candidate = candidates[index];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(candidate.seriesName),
                subtitle: Text(
                  [
                    if (candidate.poolLabel.isNotEmpty) candidate.poolLabel,
                    if (candidate.leaderNames.isNotEmpty)
                      'Holdleder: ${candidate.leaderNames.join(', ')}',
                    'team ${candidate.dbuTeamId}',
                    'pool ${candidate.dbuPoolId}',
                  ].join('\n'),
                ),
                onTap: () => Navigator.of(dialogContext).pop(candidate),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Annuller'),
          ),
        ],
      ),
    );
  }

  static String _seasonName(Map<String, dynamic> resultData) {
    final season = resultData['season']?.toString().trim();
    if (season != null && season.isNotEmpty) {
      return season;
    }

    final firstMatchDate = DateTime.now();
    return '${_seasonLabel(firstMatchDate.month)} ${firstMatchDate.year}';
  }

  static String _seasonLabel(int month) {
    if (month >= 3 && month <= 5) return 'Forår';
    if (month >= 6 && month <= 8) return 'Sommer';
    if (month >= 9 && month <= 11) return 'Efterår';
    return 'Vinter';
  }
}
