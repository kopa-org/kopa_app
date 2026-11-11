import 'dart:convert';

import 'package:kopa/helpers/api_config.dart';
import 'package:kopa/model/in_form.dart';
import 'package:kopa/services/api_client.dart';

class InFormRepository {
  static final _apiClient = ApiClient.shared;

  static Future<InFormLeaderboard> getLeaderboard({
    required int teamId,
    required InFormPeriod period,
    String? position,
  }) async {
    final json = await _get('/player_plus/in_form/leaderboard', {
      'team_id': '$teamId',
      'period': period.wire,
      if (position != null) 'position': position,
    });
    return InFormLeaderboard.fromJson(json['in_form_leaderboard']);
  }

  static Future<InFormPlayerBreakdown> getPlayerBreakdown({
    required int teamId,
    required int playerId,
    required InFormPeriod period,
  }) async {
    final json = await _get('/player_plus/in_form/player/$playerId', {
      'team_id': '$teamId',
      'period': period.wire,
    });
    return InFormPlayerBreakdown.fromJson(json['in_form_player']);
  }

  static Future<InFormPointsSystem> getPointsSystem() async {
    final json = await _get('/player_plus/in_form/points_system', const {});
    return InFormPointsSystem.fromJson(json['in_form_points_system']);
  }

  /// Registers per-match in-form data for a player. Pass `null` for a field
  /// to clear its override and fall back to the derived value.
  static Future<void> updateMatchPerformance({
    required int eventId,
    required int playerId,
    required Map<String, Object?> changes,
  }) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/player_plus/in_form/matches/$eventId/players/$playerId',
    );
    final response = await _apiClient.patchJson(uri, body: changes);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('In-form update failed (${response.statusCode})');
    }
  }

  static Future<Map<String, dynamic>> _get(
    String path,
    Map<String, String> query,
  ) async {
    final uri =
        Uri.parse('${ApiConfig.baseUrl}$path').replace(queryParameters: query);

    final response = await _apiClient.get(uri);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('In-form request failed (${response.statusCode})');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
