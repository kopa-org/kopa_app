import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:kopa/helpers/api_config.dart';
import 'package:kopa/services/secure_storage_service.dart';

class PushNotificationsRepository {
  static const _requestTimeout = Duration(seconds: 20);
  PushNotificationsRepository({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  Future<void> registerToken({
    required String token,
    required String platform,
  }) async {
    final authToken = await SecureStorageService.getToken();
    if (authToken == null) {
      throw StateError('Cannot register push token without auth token.');
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/push_tokens');
    final response = await _httpClient
        .post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $authToken',
          },
          body: jsonEncode({
            'token': token,
            'platform': platform,
          }),
        )
        .timeout(_requestTimeout);

    if (response.statusCode != 201) {
      throw Exception('Failed to register push token.');
    }
  }

  Future<void> unregisterToken(String token) async {
    final authToken = await SecureStorageService.getToken();
    if (authToken == null) {
      return;
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/push_tokens');
    final response = await _httpClient
        .delete(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $authToken',
          },
          body: jsonEncode({'token': token}),
        )
        .timeout(_requestTimeout);

    if (response.statusCode != 200 && response.statusCode != 404) {
      throw Exception('Failed to unregister push token.');
    }
  }
}
