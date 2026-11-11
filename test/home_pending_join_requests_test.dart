import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/cubits/home_cubit.dart';

void main() {
  test('team owners get the pending join request count', () async {
    final cubit = HomeCubit(
      canApproveJoinRequests: () => true,
      countJoinRequests: (_) async => 3,
    );
    addTearDown(cubit.close);

    await cubit.loadPendingJoinRequests(7);

    expect(cubit.state.pendingJoinRequests, 3);
  });

  test('players never load or show join requests', () async {
    var called = false;
    final cubit = HomeCubit(
      canApproveJoinRequests: () => false,
      countJoinRequests: (_) async {
        called = true;
        return 3;
      },
    );
    addTearDown(cubit.close);

    await cubit.loadPendingJoinRequests(7);

    expect(called, isFalse);
    expect(cubit.state.pendingJoinRequests, 0);
  });

  test('a failed refresh keeps the last known count', () async {
    var fail = false;
    final cubit = HomeCubit(
      canApproveJoinRequests: () => true,
      countJoinRequests: (_) async {
        if (fail) throw Exception('offline');
        return 2;
      },
    );
    addTearDown(cubit.close);

    await cubit.loadPendingJoinRequests(7);
    fail = true;
    await cubit.loadPendingJoinRequests(7);

    expect(cubit.state.pendingJoinRequests, 2);
  });

  test('approving everyone clears the badge', () async {
    var count = 2;
    final cubit = HomeCubit(
      canApproveJoinRequests: () => true,
      countJoinRequests: (_) async => count,
    );
    addTearDown(cubit.close);

    await cubit.loadPendingJoinRequests(7);
    count = 0;
    await cubit.loadPendingJoinRequests(7);

    expect(cubit.state.pendingJoinRequests, 0);
  });

  test('a join request push refreshes the badge live', () async {
    final pushes = StreamController<Map<String, dynamic>>.broadcast();
    addTearDown(pushes.close);
    var count = 1;
    final cubit = HomeCubit(
      canApproveJoinRequests: () => true,
      countJoinRequests: (_) async => count,
      pushMessages: pushes.stream,
    );
    addTearDown(cubit.close);
    await cubit.loadPendingJoinRequests(7);

    count = 2;
    pushes.add({'type': 'team_join_request', 'team_id': '7'});
    await pumpEventQueue();
    expect(cubit.state.pendingJoinRequests, 2);

    // Other notification types and other teams are ignored.
    count = 5;
    pushes.add({'type': 'match_lineup_revealed', 'team_id': '7'});
    pushes.add({'type': 'team_join_request', 'team_id': '99'});
    await pumpEventQueue();
    expect(cubit.state.pendingJoinRequests, 2);
  });

  testWidgets('returning to the app refreshes the badge', (tester) async {
    var count = 1;
    final cubit = HomeCubit(
      canApproveJoinRequests: () => true,
      countJoinRequests: (_) async => count,
      watchAppLifecycle: true,
    );
    addTearDown(cubit.close);
    await cubit.loadPendingJoinRequests(7);

    count = 4;
    // Real apps pass through these states when backgrounded and reopened.
    for (final state in const [
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(state);
    }
    await tester.pump();

    expect(cubit.state.pendingJoinRequests, 4);
  });
}
