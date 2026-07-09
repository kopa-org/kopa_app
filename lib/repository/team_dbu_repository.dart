import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:kopa/helpers/api_config.dart';
import 'package:kopa/model/dbu_standings.dart';
import 'package:kopa/services/secure_storage_service.dart';

abstract final class TeamDbuRepository {
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
      'pool_teams': scrapedData['poolTeams'],
    });
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
