import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/component/card/player_positions_card.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/theme/app_theme.dart';

void main() {
  testWidgets('saved sparse lineup slots stay in their persisted positions',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final nicklas =
        _user(id: 1, name: 'Nicklas Hansen', position: 'midfielder');

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: PlayerPositionsCard(
            playerCount: 7,
            formation: '2-3-1',
            players: [nicklas],
            positionedPlayers: [null, null, null, nicklas, null, null, null],
            preservePlayerOrder: true,
          ),
        ),
      ),
    );

    final nicklasCenter = tester.getCenter(find.text('Nicklas'));
    final goalkeeperCenter = tester.getCenter(find.text('MM'));

    expect(nicklasCenter.dy, greaterThan(goalkeeperCenter.dy + 80));
  });
}

UserDetails _user({
  required int id,
  required String name,
  String? position,
}) {
  final now = DateTime.utc(2026, 1, 1);

  return UserDetails(
    id: id,
    name: name,
    email: 'user$id@example.com',
    isTeamOwner: false,
    roleId: 3,
    position: position,
    createdAt: now,
    updatedAt: now,
    teamDetails: null,
  );
}
