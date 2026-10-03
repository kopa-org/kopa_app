import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/component/card/player_positions_card.dart';
import 'package:kopa/component/football_pitch.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/model/match_player.dart';
import 'package:kopa/theme/app_theme.dart';

void main() {
  for (final (language, message) in [
    ('en', 'Waiting for lineup'),
    ('da', 'Venter på holdopstilling'),
  ]) {
    testWidgets('$language hidden lineup shows anonymous pitch until revealed',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final player = _player(id: 1, name: 'Hidden Player');

      Future<void> pumpCard({required bool waiting}) async {
        await tester.pumpWidget(MaterialApp(
          theme: AppTheme.lightTheme,
          locale: Locale(language),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: PlayerPositionsCard(
              playerCount: 7,
              formation: '3-2-1',
              players: [player],
              positionedPlayers: [player],
              isWaitingForLineup: waiting,
              isVisibleToPlayers: !waiting,
              // Waiting must omit controls even with callbacks provided.
              onEditFormation: waiting ? () {} : null,
              onToggleVisibility: waiting ? () {} : null,
            ),
          ),
        ));
      }

      await pumpCard(waiting: true);
      expect(find.text(message), findsOneWidget);
      expect(find.byType(FootballPitch), findsOneWidget);
      expect(find.byType(ImageFiltered), findsOneWidget);
      expect(find.text('Hidden Player'), findsNothing);
      expect(find.text('3-2-1'), findsNothing);
      expect(find.text('På bænken:'), findsNothing);
      expect(find.byType(CupertinoButton), findsNothing);
      expect(find.byType(Tooltip).hitTestable(), findsNothing);
      expect(tester.takeException(), isNull);

      await pumpCard(waiting: false);
      expect(find.text(message), findsNothing);
      expect(find.byType(ImageFiltered), findsNothing);
      expect(find.text('Hidden Player'), findsOneWidget);
      expect(find.text('3-2-1'), findsOneWidget);
      expect(find.byType(CupertinoButton), findsNothing);
    });
  }

  testWidgets('visibility control defaults to hidden', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: PlayerPositionsCard(
            playerCount: 7,
            formation: '2-3-1',
            players: [_player(id: 1, name: 'Nicklas Hansen')],
            onToggleVisibility: () {},
          ),
        ),
      ),
    );

    expect(find.byIcon(CupertinoIcons.eye), findsNothing);
    expect(find.byIcon(CupertinoIcons.eye_slash), findsOneWidget);
  });

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
            players: [MatchPlayer.user(nicklas)],
            positionedPlayers: [
              null,
              null,
              null,
              MatchPlayer.user(nicklas),
              null,
              null,
              null,
            ],
            preservePlayerOrder: true,
          ),
        ),
      ),
    );

    final nicklasCenter = tester.getCenter(find.text('Nicklas Hansen'));
    final goalkeeperCenter = tester.getCenter(find.text('MM'));

    expect(nicklasCenter.dy, greaterThan(goalkeeperCenter.dy + 80));
  });

  testWidgets('visibility toggle swaps between eye states', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var visible = false;

    Future<void> pumpCard() async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return PlayerPositionsCard(
                  playerCount: 7,
                  formation: '2-3-1',
                  players: [_player(id: 1, name: 'Nicklas Hansen')],
                  isVisibleToPlayers: visible,
                  onToggleVisibility: () {
                    setState(() {
                      visible = !visible;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );
    }

    await pumpCard();

    expect(find.byIcon(CupertinoIcons.eye), findsNothing);
    expect(find.byIcon(CupertinoIcons.eye_slash), findsOneWidget);

    await tester.tap(find.byIcon(CupertinoIcons.eye_slash));
    await tester.pump();

    expect(find.byIcon(CupertinoIcons.eye), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.eye_slash), findsNothing);
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

MatchPlayer _player({required int id, required String name}) {
  return MatchPlayer.user(_user(id: id, name: name));
}
