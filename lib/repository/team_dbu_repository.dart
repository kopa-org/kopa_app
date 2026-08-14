import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:kopa/helpers/api_config.dart';
import 'package:kopa/model/dbu_standings.dart';
import 'package:kopa/services/secure_storage_service.dart';

abstract final class TeamDbuRepository {
  static Future<DbuPublicClubTeamsResult> getPublicClubTeams({
    required int clubId,
    required String teamLabel,
    required String leaderLabel,
  }) async {
    final token = await SecureStorageService.getToken();
    if (token == null) {
      throw Exception('Ikke logget ind.');
    }

    final uri = Uri.parse('${ApiConfig.baseUrl}/dbu/public/club_teams')
        .replace(queryParameters: {
      'club_id': clubId.toString(),
      if (teamLabel.trim().isNotEmpty) 'team_label': teamLabel.trim(),
      if (leaderLabel.trim().isNotEmpty) 'leader_label': leaderLabel.trim(),
    });

    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    final decoded = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return DbuPublicClubTeamsResult.fromJson(decoded);
    }

    throw Exception(decoded['error'] ?? 'Kunne ikke hente DBU-hold.');
  }

  static Future<DbuPublicClubTeamsResult> resolvePublicTeam({
    required String clubName,
    required String teamLabel,
    required String leaderLabel,
  }) async {
    final token = await SecureStorageService.getToken();
    if (token == null) {
      throw Exception('Ikke logget ind.');
    }

    final uri = Uri.parse('${ApiConfig.baseUrl}/dbu/public/resolve_team')
        .replace(queryParameters: {
      'club_name': clubName.trim(),
      'team_label': teamLabel.trim(),
      'leader_label': leaderLabel.trim(),
    });

    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    final decoded = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return DbuPublicClubTeamsResult.fromJson(decoded);
    }

    throw Exception(decoded['error'] ?? 'Kunne ikke finde DBU-holdet.');
  }

  static Future<DbuStandings?> getStandings(int teamId) async {
    final token = await SecureStorageService.getToken();
    if (token == null) {
      throw Exception('Ikke logget ind.');
    }

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/teams/$teamId/dbu/standings'),
      headers: {'Authorization': 'Bearer $token'},
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
    final token = await SecureStorageService.getToken();
    if (token == null) {
      throw Exception('Ikke logget ind.');
    }

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}$path'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
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
