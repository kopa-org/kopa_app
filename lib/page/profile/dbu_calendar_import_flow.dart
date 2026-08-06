import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kopa/navigation/app_router.dart';
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

    final resultData = _decodeResult(result);
    if (resultData['dbuTeamId'] == null || resultData['dbuPoolId'] == null) {
      return null;
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
        startsOn: _earliestMatchDate(resultData) ?? DateTime.now(),
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

    return {'matches': []};
  }

  static DateTime? _earliestMatchDate(Map<String, dynamic> resultData) {
    final matches = resultData['matches'];
    if (matches is! List<dynamic>) {
      return null;
    }

    final dates = matches
        .whereType<Map<dynamic, dynamic>>()
        .map((match) => match['dtstart']?.toString())
        .whereType<String>()
        .map(_parseDbuDate)
        .whereType<DateTime>()
        .toList()
      ..sort();

    return dates.isEmpty ? null : dates.first;
  }

  static String _seasonName(Map<String, dynamic> resultData) {
    final season = resultData['season']?.toString().trim();
    if (season != null && season.isNotEmpty) {
      return season;
    }

    final firstMatchDate = _earliestMatchDate(resultData) ?? DateTime.now();
    return '${_seasonLabel(firstMatchDate.month)} ${firstMatchDate.year}';
  }

  static String _seasonLabel(int month) {
    if (month >= 3 && month <= 5) return 'Forår';
    if (month >= 6 && month <= 8) return 'Sommer';
    if (month >= 9 && month <= 11) return 'Efterår';
    return 'Vinter';
  }

  static DateTime? _parseDbuDate(String value) {
    final isoDate = DateTime.tryParse(value);
    if (isoDate != null) {
      return isoDate;
    }

    final match = RegExp(r'^(\d{4})(\d{2})(\d{2})T(\d{2})(\d{2})(\d{2})Z?$')
        .firstMatch(value);
    if (match == null) {
      return null;
    }

    return DateTime.utc(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
      int.parse(match.group(4)!),
      int.parse(match.group(5)!),
      int.parse(match.group(6)!),
    );
  }
}
