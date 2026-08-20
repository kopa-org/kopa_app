import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:kopa/helpers/api_config.dart';
import 'package:kopa/model/player_plus.dart';
import 'package:kopa/services/api_client.dart';

class PlayerPlusRepository {
  static final _apiClient = ApiClient.shared;

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
    final url =
        Uri.parse('${ApiConfig.baseUrl}$path').replace(queryParameters: query);

    final response = await _apiClient.get(url);

    return _decodeResponse(response);
  }

  static Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$path');

    final response = await _apiClient.postJson(
      url,
      body: body,
    );

    return _decodeResponse(response);
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
