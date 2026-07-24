import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:kopa/config/app_feature_flags.dart';
import 'package:kopa/helpers/api_config.dart';

class FeatureFlagsRepository {
  FeatureFlagsRepository({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  Future<AppFeatureFlags> getFeatureFlags() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/features');

    try {
      final response = await _httpClient.get(url);
      if (response.statusCode != 200) return const AppFeatureFlags();

      final body = jsonDecode(response.body);
      final features = body is Map<String, dynamic> ? body['features'] : null;

      if (features is! Map<String, dynamic>) {
        return const AppFeatureFlags();
      }

      return AppFeatureFlags.fromJson(features);
    } catch (error) {
      if (kDebugMode) {
        print('Feature flags fetch failed: $error');
      }
      return const AppFeatureFlags();
    }
  }
}
