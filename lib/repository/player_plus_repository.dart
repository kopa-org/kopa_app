import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:kopa/helpers/api_config.dart';
import 'package:kopa/model/player_plus.dart';

class PlayerPlusRepository {
  static final _secureStorage = FlutterSecureStorage();

  static Future<PlayerPlusEntitlement> getEntitlement({int? teamId}) async {
    final json = await _get(
      '/player_plus/entitlement',
      query: teamId == null ? null : {'team_id': teamId.toString()},
    );

    return PlayerPlusEntitlement.fromJson(json['entitlement']);
  }

  static Future<PlayerPlusOverview> getOverview(int teamId) async {
    final json = await _get(
      '/player_plus/overview',
      query: {'team_id': teamId.toString()},
    );

    return PlayerPlusOverview.fromJson(json['player_plus']);
  }

  static Future<PlayerPlusLeaderboard> getLeaderboard({
    required int teamId,
    String scope = 'team',
    String category = 'goals',
  }) async {
    final json = await _get(
      '/player_plus/leaderboards',
      query: {
        'team_id': teamId.toString(),
        'scope': scope,
        'category': category,
      },
    );

    return PlayerPlusLeaderboard.fromJson(json['leaderboard']);
  }

  static Future<void> ratePlayer({
    required int eventId,
    required int ratedUserId,
    required int rating,
    String? award,
  }) async {
    await _post('/player_plus/ratings', {
      'event_id': eventId,
      'rated_user_id': ratedUserId,
      'rating': rating,
      if (award != null) 'award': award,
    });
  }

  static Future<Map<String, dynamic>> _get(
    String path, {
    Map<String, String>? query,
  }) async {
    final token = await _token();
    final url =
        Uri.parse('${ApiConfig.baseUrl}$path').replace(queryParameters: query);

    final response = await http.get(
      url,
      headers: _headers(token),
    );

    return _decodeResponse(response);
  }

  static Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final token = await _token();
    final url = Uri.parse('${ApiConfig.baseUrl}$path');

    final response = await http.post(
      url,
      headers: _headers(token),
      body: jsonEncode(body),
    );

    return _decodeResponse(response);
  }

  static Future<String> _token() async {
    final token = await _secureStorage.read(key: 'token');
    if (token == null) {
      throw Exception('No token found. User might not be logged in.');
    }
    return token;
  }

  static Map<String, String> _headers(String token) {
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  static Map<String, dynamic> _decodeResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    }

    if (response.statusCode == 401) {
      throw Exception('Unauthorized. Please log in again.');
    }

    throw Exception(
        'Player+ request failed with status ${response.statusCode}');
  }
}
