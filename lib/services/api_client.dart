import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:kopa/services/secure_storage_service.dart';

/// Shared HTTP transport for API repositories.
///
/// Keeping one client lets the platform reuse connections and gives every
/// request a bounded timeout. Repositories can still keep their existing
/// static API while they migrate to injected repository instances.
class ApiClient {
  ApiClient({http.Client? client, this.timeout = const Duration(seconds: 20)})
      : _client = client ?? http.Client();

  static final ApiClient shared = ApiClient();

  final http.Client _client;
  final Duration timeout;

  Future<http.Response> get(
    Uri url, {
    Map<String, String>? headers,
    bool authenticated = true,
  }) {
    return _send(
      () async => _client.get(
        url,
        headers: await _headers(
          headers,
          authenticated: authenticated,
        ),
      ),
    );
  }

  Future<http.Response> postJson(
    Uri url, {
    Object? body,
    Map<String, String>? headers,
    bool authenticated = true,
  }) {
    return _send(
      () async => _client.post(
        url,
        headers: await _headers(
          {
            'Content-Type': 'application/json',
            ...?headers,
          },
          authenticated: authenticated,
        ),
        body: body == null ? null : jsonEncode(body),
      ),
    );
  }

  Future<http.Response> post(
    Uri url, {
    Object? body,
    Map<String, String>? headers,
    bool authenticated = true,
  }) {
    return _send(
      () async => _client.post(
        url,
        headers: await _headers(headers, authenticated: authenticated),
        body: body,
      ),
    );
  }

  Future<http.Response> patchJson(
    Uri url, {
    Object? body,
    Map<String, String>? headers,
    bool authenticated = true,
  }) {
    return _send(
      () async => _client.patch(
        url,
        headers: await _headers(
          {
            'Content-Type': 'application/json',
            ...?headers,
          },
          authenticated: authenticated,
        ),
        body: body == null ? null : jsonEncode(body),
      ),
    );
  }

  Future<http.Response> patch(
    Uri url, {
    Object? body,
    Map<String, String>? headers,
    bool authenticated = true,
  }) {
    return _send(
      () async => _client.patch(
        url,
        headers: await _headers(headers, authenticated: authenticated),
        body: body,
      ),
    );
  }

  Future<http.Response> delete(
    Uri url, {
    Map<String, String>? headers,
    bool authenticated = true,
  }) {
    return _send(
      () async => _client.delete(
        url,
        headers: await _headers(
          headers,
          authenticated: authenticated,
        ),
      ),
    );
  }

  Future<http.Response> _send(Future<http.Response> Function() request) {
    return request().timeout(timeout);
  }

  Future<Map<String, String>> _headers(
    Map<String, String>? headers, {
    required bool authenticated,
  }) async {
    final merged = <String, String>{...?headers};

    if (authenticated && !merged.containsKey('Authorization')) {
      final token = await SecureStorageService.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('No token found. User might not be logged in.');
      }
      merged['Authorization'] = 'Bearer $token';
    }

    return merged;
  }

  void close() => _client.close();
}
