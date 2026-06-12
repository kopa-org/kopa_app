import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:kopa/helpers/api_config.dart';
import 'package:kopa/model/in_form.dart';
import 'package:kopa/services/secure_storage_service.dart';

class InFormConflictException implements Exception {}

class InFormRepository {
  static Future<InFormLeaderboard> getLeaderboard({
    required int teamId,
    required InFormPeriod period,
    String? position,
  }) async {
    final json = await _get('/in_form/leaderboard', {
      'team_id': '$teamId',
      'period': period.wire,
      if (position != null) 'position': position,
    });
    return InFormLeaderboard.fromJson(json['leaderboard']);
  }

  static Future<InFormPlayerBreakdown> getPlayerBreakdown({
    required int teamId,
    required int playerId,
    required InFormPeriod period,
  }) async {
    final json = await _get('/in_form/player/$playerId', {
      'team_id': '$teamId',
      'period': period.wire,
    });
    return InFormPlayerBreakdown.fromJson(json['player']);
  }

  static Future<InFormMatchRecord> getMatchRecord(int eventId) async {
    final json = await _get('/in_form/matches/$eventId', const {});
    return InFormMatchRecord.fromJson(json['match_record']);
  }

  static Future<InFormMatchRecord> updateMatchRecord({
    required InFormMatchRecord record,
    required List<InFormPerformance> performances,
    required bool cancelled,
  }) async {
    final json = await _request(
      'PUT',
      '/in_form/matches/${record.eventId}',
      body: {
        'version': record.version,
        'data': {
          'cancelled': cancelled,
          'performances':
              performances.map((performance) => performance.toJson()).toList(),
        },
      },
    );
    return InFormMatchRecord.fromJson(json['match_record']);
  }

  static Future<Map<String, dynamic>> _get(
    String path,
    Map<String, String> query,
  ) {
    return _request('GET', path, query: query);
  }

  static Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, String>? query,
    Map<String, dynamic>? body,
  }) async {
    final token = await SecureStorageService.getToken();
    final uri =
        Uri.parse('${ApiConfig.baseUrl}$path').replace(queryParameters: query);
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    final response = method == 'PUT'
        ? await http.put(uri, headers: headers, body: jsonEncode(body))
        : await http.get(uri, headers: headers);

    if (response.statusCode == 409) throw InFormConflictException();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('In-form request failed (${response.statusCode})');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
