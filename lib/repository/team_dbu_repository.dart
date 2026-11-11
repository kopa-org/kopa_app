import 'dart:convert';

import 'package:kopa/helpers/api_config.dart';
import 'package:kopa/model/dbu_standings.dart';
import 'package:kopa/services/api_client.dart';

abstract final class TeamDbuRepository {
  static final _apiClient = ApiClient.shared;

  static Future<DbuPublicClubTeamsResult> resolvePublicTeam({
    required String clubName,
    required String teamLabel,
    required String leaderLabel,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/dbu/public/resolve_team')
        .replace(queryParameters: {
      'club_name': clubName.trim(),
      'team_label': teamLabel.trim(),
      'leader_label': leaderLabel.trim(),
    });

    final response = await _apiClient.get(uri);

    final decoded = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return DbuPublicClubTeamsResult.fromJson(decoded);
    }

    throw Exception(decoded['error'] ?? 'Kunne ikke finde DBU-holdet.');
  }

  /// Suggests the DBU pool to import for a new season, based on the pool the
  /// team just played. Returns an empty list when nothing could be found, so
  /// callers can fall back to the manual DBU import.
  static Future<List<DbuNextSeasonCandidate>> findNextSeason(int teamId) async {
    try {
      final response = await _apiClient.get(
        Uri.parse('${ApiConfig.baseUrl}/teams/$teamId/dbu/next_season'),
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return const [];
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final candidates = decoded['candidates'];
      if (candidates is! List<dynamic>) return const [];

      return candidates
          .whereType<Map<String, dynamic>>()
          .map(DbuNextSeasonCandidate.fromJson)
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  /// Whether the team's next DBU season is published yet. Used by the home
  /// screen once the current season has no matches left. [refresh] asks the
  /// backend to re-check DBU (it rate limits this itself).
  static Future<DbuSeasonOutlook> getSeasonOutlook(
    int teamId, {
    bool refresh = false,
  }) async {
    final uri =
        Uri.parse('${ApiConfig.baseUrl}/teams/$teamId/dbu/season_outlook')
            .replace(queryParameters: refresh ? {'refresh': 'true'} : null);
    final response = await _apiClient.get(uri);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Season outlook failed (${response.statusCode})');
    }
    return DbuSeasonOutlook.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  static Future<DbuStandings?> getStandings(int teamId) async {
    final response = await _apiClient.get(
      Uri.parse('${ApiConfig.baseUrl}/teams/$teamId/dbu/standings'),
    );

    final decoded = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final standings = decoded['standings'] as Map<String, dynamic>?;
      if (standings == null) return null;
      return DbuStandings.fromJson({
        ...standings,
        'currentTeamId': decoded['dbu_team_id'],
        'seriesName': decoded['series_name'],
        'poolTeams': decoded['pool_teams'],
      });
    }

    throw Exception(decoded['error'] ?? 'Kunne ikke hente DBU-stillingen.');
  }

  static Future<Map<String, dynamic>> syncStandings({
    required int teamId,
    required Map<String, dynamic> scrapedData,
  }) {
    return _post('/teams/$teamId/dbu/standings/sync', {
      'dbu_team_id': scrapedData['dbuTeamId'],
      'dbu_pool_id': scrapedData['dbuPoolId'],
      'dbu_team_label': scrapedData['dbuTeamLabel'],
      'series_name': scrapedData['seriesName'],
      'standings': scrapedData['standings'],
      'pool_teams': _poolTeamsWithoutLogos(scrapedData['poolTeams']),
    });
  }

  static List<dynamic> _poolTeamsWithoutLogos(dynamic poolTeams) {
    if (poolTeams is! List<dynamic>) {
      return const [];
    }

    return poolTeams
        .whereType<Map<dynamic, dynamic>>()
        .map((team) => {
              if (team['dbuTeamId'] != null) 'dbuTeamId': team['dbuTeamId'],
              if (team['dbu_team_id'] != null)
                'dbu_team_id': team['dbu_team_id'],
              if (team['name'] != null) 'name': team['name'],
            })
        .toList(growable: false);
  }

  static Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await _apiClient.postJson(
      Uri.parse('${ApiConfig.baseUrl}$path'),
      body: body,
    );

    final decoded = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }

    throw Exception(decoded['error'] ?? 'DBU-synkronisering fejlede.');
  }
}

class DbuPublicClubTeamsResult {
  final int clubId;
  final String sourceUrl;
  final List<DbuPublicClubTeam> teams;

  const DbuPublicClubTeamsResult({
    required this.clubId,
    required this.sourceUrl,
    required this.teams,
  });

  factory DbuPublicClubTeamsResult.fromJson(Map<String, dynamic> json) {
    final teams = json['teams'];

    return DbuPublicClubTeamsResult(
      clubId: _intFromJson(json['clubId']) ?? 0,
      sourceUrl: json['sourceUrl']?.toString() ?? '',
      teams: teams is List<dynamic>
          ? teams
              .whereType<Map<String, dynamic>>()
              .map(DbuPublicClubTeam.fromJson)
              .toList(growable: false)
          : const [],
    );
  }
}

class DbuPublicClubTeam {
  final int dbuTeamId;
  final int dbuPoolId;
  final String seriesName;
  final String poolLabel;
  final String url;
  final String infoUrl;
  final List<String> leaderNames;
  final int matchScore;
  final int leaderMatchScore;
  final int combinedScore;

  const DbuPublicClubTeam({
    required this.dbuTeamId,
    required this.dbuPoolId,
    required this.seriesName,
    required this.poolLabel,
    required this.url,
    required this.infoUrl,
    required this.leaderNames,
    required this.matchScore,
    required this.leaderMatchScore,
    required this.combinedScore,
  });

  factory DbuPublicClubTeam.fromJson(Map<String, dynamic> json) {
    return DbuPublicClubTeam(
      dbuTeamId: _intFromJson(json['dbuTeamId']) ?? 0,
      dbuPoolId: _intFromJson(json['dbuPoolId']) ?? 0,
      seriesName: json['seriesName']?.toString() ?? '',
      poolLabel: json['poolLabel']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      infoUrl: json['infoUrl']?.toString() ?? '',
      leaderNames: json['leaderNames'] is List<dynamic>
          ? (json['leaderNames'] as List<dynamic>)
              .map((value) => value.toString())
              .where((value) => value.isNotEmpty)
              .toList(growable: false)
          : const [],
      matchScore: _intFromJson(json['matchScore']) ?? 0,
      leaderMatchScore: _intFromJson(json['leaderMatchScore']) ?? 0,
      combinedScore: _intFromJson(json['combinedScore']) ?? 0,
    );
  }
}

int? _intFromJson(dynamic value) {
  if (value is int) return value;
  if (value is String) return int.tryParse(value);
  return null;
}

class DbuNextSeasonCandidate {
  final int dbuTeamId;
  final int dbuPoolId;
  final String teamName;
  final String seriesName;
  final String poolLabel;
  final String seasonLabel;
  final int upcomingMatchCount;
  final DateTime? firstUpcomingMatchOn;

  const DbuNextSeasonCandidate({
    required this.dbuTeamId,
    required this.dbuPoolId,
    required this.teamName,
    required this.seriesName,
    required this.poolLabel,
    this.seasonLabel = '',
    required this.upcomingMatchCount,
    required this.firstUpcomingMatchOn,
  });

  factory DbuNextSeasonCandidate.fromJson(Map<String, dynamic> json) {
    return DbuNextSeasonCandidate(
      dbuTeamId: _intFromJson(json['dbuTeamId']) ?? 0,
      dbuPoolId: _intFromJson(json['dbuPoolId']) ?? 0,
      teamName: json['teamName']?.toString() ?? '',
      seriesName: json['seriesName']?.toString() ?? '',
      poolLabel: json['poolLabel']?.toString() ?? '',
      seasonLabel: json['seasonLabel']?.toString() ?? '',
      upcomingMatchCount: _intFromJson(json['upcomingMatchCount']) ?? 0,
      firstUpcomingMatchOn:
          DateTime.tryParse(json['firstUpcomingMatchOn']?.toString() ?? ''),
    );
  }

  /// The DBU context the calendar import expects. Deliberately leaves out the
  /// team label and club name so the Kopa team keeps its current name.
  /// Includes the DBU season label (e.g. "Forår 2027") when known, so the new
  /// Kopa season is named after it rather than after today's date.
  Map<String, dynamic> toImportContext() => {
        'dbuTeamId': dbuTeamId,
        'dbuPoolId': dbuPoolId,
        'seriesName': seriesName,
        'poolLabel': poolLabel,
        if (seasonLabel.isNotEmpty) 'season': seasonLabel,
      };
}

enum DbuSeasonOutlookStatus {
  /// The next season is published on DBU and can be imported.
  ready,

  /// Nothing published yet (or DBU could not be reached).
  waiting,

  /// No DBU link or lookups disabled: only a manual import is possible.
  unavailable,
}

class DbuSeasonOutlook {
  final DbuSeasonOutlookStatus status;
  final List<DbuNextSeasonCandidate> candidates;
  final DateTime? checkedAt;

  const DbuSeasonOutlook({
    required this.status,
    this.candidates = const [],
    this.checkedAt,
  });

  DbuNextSeasonCandidate? get bestCandidate =>
      candidates.isEmpty ? null : candidates.first;

  factory DbuSeasonOutlook.fromJson(Map<String, dynamic> json) {
    final candidates = json['candidates'] is List<dynamic>
        ? (json['candidates'] as List<dynamic>)
            .whereType<Map<String, dynamic>>()
            .map(DbuNextSeasonCandidate.fromJson)
            .toList(growable: false)
        : const <DbuNextSeasonCandidate>[];
    final status = switch (json['status']) {
      'ready' when candidates.isNotEmpty => DbuSeasonOutlookStatus.ready,
      'unavailable' => DbuSeasonOutlookStatus.unavailable,
      _ => DbuSeasonOutlookStatus.waiting,
    };

    return DbuSeasonOutlook(
      status: status,
      candidates: candidates,
      checkedAt:
          DateTime.tryParse(json['checked_at']?.toString() ?? '')?.toLocal(),
    );
  }
}
