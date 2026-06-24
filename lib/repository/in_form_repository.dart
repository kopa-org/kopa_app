import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:kopa/helpers/api_config.dart';
import 'package:kopa/model/in_form.dart';
import 'package:kopa/services/secure_storage_service.dart';

class InFormRepository {
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

  static Future<Map<String, dynamic>> _get(
    String path,
    Map<String, String> query,
  ) async {
    final token = await SecureStorageService.getToken();
    final uri =
        Uri.parse('${ApiConfig.baseUrl}$path').replace(queryParameters: query);
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    final response = await http.get(uri, headers: headers);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('In-form request failed (${response.statusCode})');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
