import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:kopa/config/app_feature_flags.dart';
import 'package:kopa/helpers/api_config.dart';
import 'package:kopa/services/secure_storage_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

typedef CurrentBuildNumberProvider = Future<int?> Function();
typedef AuthTokenProvider = Future<String?> Function();

class FeatureFlagsRepository {
  static const _requestTimeout = Duration(seconds: 20);
  FeatureFlagsRepository({
    http.Client? httpClient,
    CurrentBuildNumberProvider? currentBuildNumberProvider,
    AuthTokenProvider? authTokenProvider,
  })  : _httpClient = httpClient ?? http.Client(),
        _currentBuildNumberProvider =
            currentBuildNumberProvider ?? _currentBuildNumberFromPackageInfo,
        _authTokenProvider = authTokenProvider ?? SecureStorageService.getToken;

  final http.Client _httpClient;
  final CurrentBuildNumberProvider _currentBuildNumberProvider;
  final AuthTokenProvider _authTokenProvider;
  bool _closed = false;

  Future<AppFeatureFlags> getFeatureFlags() async {
    try {
      final currentBuildNumber = await _safeCurrentBuildNumber();
      final url = _featureFlagsUri('/features', currentBuildNumber);
      final response = await _httpClient
          .get(url, headers: await _authHeaders())
          .timeout(_requestTimeout);
      if (response.statusCode != 200) return const AppFeatureFlags();

      final body = jsonDecode(response.body);
      final features = body is Map<String, dynamic> ? body['features'] : null;

      if (features is! Map<String, dynamic>) {
        return const AppFeatureFlags();
      }

      return AppFeatureFlags.fromJson(
        features,
        currentBuildNumber: currentBuildNumber,
      );
    } catch (error) {
      if (kDebugMode) {
        print('Feature flags fetch failed: $error');
      }
      return const AppFeatureFlags();
    }
  }

  /// Streams feature flags over SSE, reconnecting on failure.
  ///
  /// The server resolves team-scoped flags from the auth token at connect
  /// time, so cancelling the subscription closes the current connection and
  /// stops reconnecting; callers re-listen after the auth scope changes.
  Stream<AppFeatureFlags> watchFeatureFlags({
    Duration reconnectDelay = const Duration(seconds: 5),
  }) {
    var cancelled = false;
    StreamSubscription<String>? linesSubscription;
    Completer<void>? connectionDone;
    late final StreamController<AppFeatureFlags> controller;

    bool isActive() => !_closed && !cancelled;

    Future<void> run() async {
      final currentBuildNumber = await _safeCurrentBuildNumber();
      final Uri url;
      try {
        url = _featureFlagsUri('/features/stream', currentBuildNumber);
      } catch (error) {
        if (kDebugMode) {
          print('Feature flags stream unavailable: $error');
        }
        return;
      }

      while (isActive()) {
        try {
          final headers = {
            'accept': 'text/event-stream',
            'cache-control': 'no-cache',
            ...await _authHeaders(),
          };
          final request = http.Request('GET', url)..headers.addAll(headers);
          final response = await _httpClient.send(request).timeout(
                _requestTimeout,
              );
          if (!isActive()) return;

          if (response.statusCode == 200) {
            final dataLines = <String>[];
            final done = Completer<void>();
            connectionDone = done;
            linesSubscription = response.stream
                .transform(utf8.decoder)
                .transform(const LineSplitter())
                .listen(
              (line) {
                if (line.isEmpty) {
                  final featureFlags = _parseSseData(
                    dataLines,
                    currentBuildNumber: currentBuildNumber,
                  );
                  dataLines.clear();
                  if (featureFlags != null && isActive()) {
                    controller.add(featureFlags);
                  }
                  return;
                }

                if (line.startsWith('data:')) {
                  dataLines.add(line.substring(5).trimLeft());
                }
              },
              onError: (Object error) {
                if (kDebugMode) {
                  print('Feature flags stream failed: $error');
                }
                if (!done.isCompleted) done.complete();
              },
              onDone: () {
                if (!done.isCompleted) done.complete();
              },
              cancelOnError: true,
            );
            await done.future;
            linesSubscription = null;
            connectionDone = null;
          }
        } catch (error) {
          if (kDebugMode) {
            print('Feature flags stream failed: $error');
          }
        }

        if (isActive()) {
          await Future<void>.delayed(reconnectDelay);
        }
      }
    }

    controller = StreamController<AppFeatureFlags>(
      onListen: () {
        unawaited(run().whenComplete(() {
          if (!controller.isClosed) controller.close();
        }));
      },
      onCancel: () async {
        cancelled = true;
        await linesSubscription?.cancel();
        final done = connectionDone;
        if (done != null && !done.isCompleted) done.complete();
      },
    );

    return controller.stream;
  }

  void close() {
    _closed = true;
    _httpClient.close();
  }

  Future<int?> _safeCurrentBuildNumber() async {
    try {
      return await _currentBuildNumberProvider();
    } catch (error) {
      if (kDebugMode) {
        print('App build number unavailable: $error');
      }
      return null;
    }
  }

  Future<Map<String, String>> _authHeaders() async {
    final token = await _authTokenProvider();
    if (token == null || token.isEmpty) return const {};

    return {'Authorization': 'Bearer $token'};
  }

  Uri _featureFlagsUri(String path, int? currentBuildNumber) {
    final url = Uri.parse('${ApiConfig.baseUrl}$path');
    if (currentBuildNumber == null) return url;

    return url.replace(
      queryParameters: {
        ...url.queryParameters,
        'build_number': currentBuildNumber.toString(),
      },
    );
  }

  AppFeatureFlags? _parseSseData(
    List<String> dataLines, {
    required int? currentBuildNumber,
  }) {
    if (dataLines.isEmpty) return null;

    try {
      final body = jsonDecode(dataLines.join('\n'));
      final features = body is Map<String, dynamic> ? body['features'] : null;
      if (features is! Map<String, dynamic>) return null;
      return AppFeatureFlags.fromJson(
        features,
        currentBuildNumber: currentBuildNumber,
      );
    } catch (error) {
      if (kDebugMode) {
        print('Feature flags stream parse failed: $error');
      }
      return null;
    }
  }

  static Future<int?> _currentBuildNumberFromPackageInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return int.tryParse(packageInfo.buildNumber);
  }
}
