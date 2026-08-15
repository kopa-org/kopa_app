import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:kopa/config/app_feature_flags.dart';
import 'package:kopa/repository/feature_flags_repository.dart';

void main() {
  test('requires update when current build is below minimum build', () {
    final featureFlags = AppFeatureFlags.fromJson(
      {
        'statistics': true,
        'fine_box': false,
        'update_required': false,
        'minimum_required_build_number': 17,
      },
      currentBuildNumber: 16,
    );

    expect(featureFlags.showStatistics, isTrue);
    expect(featureFlags.updateRequired, isTrue);
    expect(featureFlags.minimumRequiredBuildNumber, 17);
    expect(featureFlags.currentBuildNumber, 16);
  });

  test('does not require update when current build matches minimum build', () {
    final featureFlags = AppFeatureFlags.fromJson(
      {
        'update_required': false,
        'minimum_required_build_number': 17,
      },
      currentBuildNumber: 17,
    );

    expect(featureFlags.updateRequired, isFalse);
  });

  test('sends current build number when fetching feature flags', () async {
    dotenv.testLoad(fileInput: 'API_BASE_URL=https://api.example.test/api');

    final repository = FeatureFlagsRepository(
      currentBuildNumberProvider: () async => 42,
      authTokenProvider: () async => 'team-token',
      httpClient: MockClient((request) async {
        expect(request.url.path, '/api/features');
        expect(request.url.queryParameters['build_number'], '42');
        expect(request.headers['Authorization'], 'Bearer team-token');

        return http.Response(
          jsonEncode({
            'features': {
              'statistics': false,
              'fine_box': false,
              'update_required': false,
              'minimum_required_build_number': 42,
            },
          }),
          200,
        );
      }),
    );
    addTearDown(repository.close);

    final featureFlags = await repository.getFeatureFlags();

    expect(featureFlags.updateRequired, isFalse);
    expect(featureFlags.currentBuildNumber, 42);
  });
}
