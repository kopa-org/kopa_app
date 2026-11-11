import 'dart:convert';

import 'package:kopa/helpers/api_config.dart';
import 'package:kopa/model/season_wrapped.dart';
import 'package:kopa/services/api_client.dart';

abstract final class SeasonWrappedRepository {
  static final _apiClient = ApiClient.shared;

  static Future<SeasonWrapped> getSeasonWrapped(int teamId) async {
    final response = await _apiClient.get(
      Uri.parse('${ApiConfig.baseUrl}/teams/$teamId/season_wrapped'),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Season Wrapped failed (${response.statusCode})');
    }
    return SeasonWrapped.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Saves which optional Wrapped categories the team leader switched off.
  static Future<void> updateDisabledCategories(
    int teamId,
    List<String> disabled,
  ) async {
    final response = await _apiClient.patchJson(
      Uri.parse('${ApiConfig.baseUrl}/teams/$teamId/settings'),
      body: {'wrapped_disabled_categories': disabled},
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Could not save Wrapped settings');
    }
  }
}
