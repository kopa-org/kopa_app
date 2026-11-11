import 'dart:convert';

import 'package:kopa/l10n/current_l10n.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kopa/navigation/app_router.dart';
import 'package:kopa/page/profile/dbu_next_season_dialog.dart';
import 'package:kopa/repository/team_dbu_repository.dart';
import 'package:kopa/repository/team_season_repository.dart';
import 'package:kopa/repository/users_repository.dart';
import 'package:kopa/utils/app_analytics.dart';

enum _CalendarImportMode { updateActiveSeason, startNewSeason }

class DbuCalendarImportFlow {
  /// Imports a DBU match schedule, optionally as a new Kopa season.
  ///
  /// The season-over screen passes [startNewSeason] to skip the "new season
  /// or update?" question, plus either the [candidate] it already found on
  /// DBU (imported directly) or [skipSuggestion] when the manager overrides
  /// the detection and wants to pick the season on Mit DBU themselves.
  static Future<String?> run(
    BuildContext context, {
    required int? teamId,
    bool startNewSeason = false,
    DbuNextSeasonCandidate? candidate,
    bool skipSuggestion = false,
  }) async {
    final mode = await _chooseImportMode(
      context,
      teamId,
      preferNewSeason: startNewSeason,
    );
    if (!context.mounted || mode == null) {
      return null;
    }

    Map<String, dynamic>? resultData = candidate?.toImportContext();
    if (candidate != null) {
      AppAnalytics.logEvent('dbu_next_season_used');
    }

    // Starting a new season: first try to find the next DBU pool from the one
    // the team just played (e.g. autumn league -> VinterBOLD), skipping the
    // Mit DBU webview when we find it.
    if (resultData == null &&
        !skipSuggestion &&
        mode == _CalendarImportMode.startNewSeason &&
        teamId != null) {
      final suggestion = await DbuNextSeasonDialog.show(
        context,
        teamId: teamId,
      );
      if (!context.mounted || suggestion.action == DbuNextSeasonAction.cancel) {
        return null;
      }

      final suggested = suggestion.candidate;
      if (suggestion.action == DbuNextSeasonAction.useCandidate &&
          suggested != null) {
        AppAnalytics.logEvent('dbu_next_season_used');
        resultData = suggested.toImportContext();
      }
    }

    if (resultData == null) {
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

      resultData = _decodeResult(result);
      if (resultData['dbuTeamId'] == null || resultData['dbuPoolId'] == null) {
        resultData = await _resolvePublicFallback(context, resultData);
        if (!context.mounted || resultData.isEmpty) {
          return null;
        }
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
        ? currentL10n.uiANewSeasonHasStartedAnd
        : currentL10n.uiTheMatchScheduleHasBeenUpdated;
  }

  static Future<_CalendarImportMode?> _chooseImportMode(
    BuildContext context,
    int? teamId, {
    bool preferNewSeason = false,
  }) async {
    if (teamId == null) {
      return _CalendarImportMode.updateActiveSeason;
    }

    final seasons = await TeamSeasonRepository.getSeasons(teamId);
    final hasActiveSeason = seasons.any((season) => season.isActive);
    if (!hasActiveSeason || !context.mounted) {
      return _CalendarImportMode.updateActiveSeason;
    }
    if (preferNewSeason) {
      return _CalendarImportMode.startNewSeason;
    }

    final startNewSeason = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.uiStartNewSeason),
        content: Text(
          AppLocalizations.of(context)!.uiNewSeasonBody,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(null),
            child: Text(AppLocalizations.of(context)!.fineBoxDeleteCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(AppLocalizations.of(context)!.uiUpdateCurrent),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(AppLocalizations.of(context)!.uiStartNewSeason2),
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
    final matchLabel = count == 1
        ? AppLocalizations.of(context)!.uiMatchSingular
        : AppLocalizations.of(context)!.uiMatchPlural;

    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.uiMissingResults),
        content: Text(
          AppLocalizations.of(context)!.uiMissingResultsBody(count, matchLabel),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(AppLocalizations.of(context)!.uiGoBack),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(AppLocalizations.of(context)!.uiStartAnyway),
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
        : await _choosePublicCandidate(
            context,
            candidates,
            teamLabel: teamLabel,
          );
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
      BuildContext context, List<DbuPublicClubTeam> candidates,
      {required String teamLabel}) {
    return showDialog<DbuPublicClubTeam>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.uiChooseDbuTeam),
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
                title: Text(teamLabel),
                subtitle: Text(
                  [
                    if (candidate.leaderNames.isNotEmpty)
                      AppLocalizations.of(context)!
                          .uiTeamLeaderNames(candidate.leaderNames.join(', ')),
                    _seasonRowLabel(candidate),
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
            child: Text(AppLocalizations.of(context)!.fineBoxDeleteCancel),
          ),
        ],
      ),
    );
  }

  static String _seasonRowLabel(DbuPublicClubTeam team) {
    if (team.poolLabel.isEmpty) return team.seriesName;
    return '${team.seriesName} · ${team.poolLabel}';
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
    if (month >= 3 && month <= 5) return currentL10n.uiSpring;
    if (month >= 6 && month <= 8) return currentL10n.uiSummer;
    if (month >= 9 && month <= 11) return currentL10n.uiAutumn;
    return currentL10n.uiWinter;
  }
}
