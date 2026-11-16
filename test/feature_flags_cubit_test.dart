import 'dart:async';
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:kopa/config/app_feature_flags.dart';
import 'package:kopa/cubits/feature_flags_cubit.dart';
import 'package:kopa/repository/feature_flags_repository.dart';

void main() {
  test('reconnects with the new auth scope and emits team flags', () async {
    dotenv.testLoad(fileInput: 'API_BASE_URL=https://api.example.test/api');
    String? token;
    final requestTokens = <String?>[];

    final repository = FeatureFlagsRepository(
      currentBuildNumberProvider: () async => 1,
      authTokenProvider: () async => token,
      httpClient: MockClient.streaming((request, _) async {
        requestTokens.add(request.headers['Authorization']);
        final enabled = request.headers['Authorization'] != null;
        final event = jsonEncode({
          'features': {'statistics': enabled, 'fine_box': enabled},
        });
        // Keep the connection open like a real SSE stream.
        final controller = StreamController<List<int>>();
        controller.add(utf8.encode('event: features\ndata: $event\n\n'));
        return http.StreamedResponse(controller.stream, 200);
      }),
    );
    final cubit = FeatureFlagsCubit(
      repository: repository,
      initialFeatureFlags: const AppFeatureFlags(),
    );
    addTearDown(cubit.close);

    cubit.startWatching();
    await cubit.updateScope(null);
    await pumpEventQueue();
    expect(cubit.state.featureFlags.showStatistics, isFalse);
    expect(requestTokens, [null]);

    // Same scope again does not reconnect.
    await cubit.updateScope(null);
    await pumpEventQueue();
    expect(requestTokens, [null]);

    token = 'team-token';
    await cubit.updateScope((1, 10));
    await pumpEventQueue();

    expect(requestTokens, [null, 'Bearer team-token']);
    expect(cubit.state.featureFlags.showStatistics, isTrue);
    expect(cubit.state.featureFlags.showFineBox, isTrue);
  });
}
