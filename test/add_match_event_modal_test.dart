import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/model/create_match_event_command.dart';
import 'package:kopa/model/match_event_type.dart';
import 'package:kopa/model/match_player.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/page/match/add_match_event_modal.dart';
import 'package:kopa/theme/app_theme.dart';

void main() {
  testWidgets('goal flow selects the scorer first and stages without a minute',
      (tester) async {
    await _open(tester);
    await tester.tap(find.text('Mål'));
    await tester.pumpAndSettle();
    expect(find.text('Målscorer'), findsOneWidget);
    expect(find.text('Vælg minut (valgfrit)'), findsNothing);

    await tester.tap(find.text('Alice Jensen'));
    await tester.pumpAndSettle();
    expect(find.text('Assist (valgfrit)'), findsOneWidget);
    expect(find.text('Alice Jensen'), findsNothing);

    await tester.tap(find.text('Tilføj mere'));
    await tester.pumpAndSettle();
    expect(find.text('Alice Jensen'), findsOneWidget);
    expect(find.text('Uden minut'), findsOneWidget);
    final save = tester.widget<CupertinoButton>(find.ancestor(
        of: find.text('Gem og afslut'),
        matching: find.byType(CupertinoButton)));
    expect(save.onPressed, isNotNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a minute can be explicitly added and removed', (tester) async {
    await _open(tester);
    await tester.tap(find.text('Mål'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Alice Jensen'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tilføj minut (valgfrit)'));
    await tester.pumpAndSettle();
    expect(find.text('Vælg minut (valgfrit)'), findsOneWidget);
    final picker = tester.widget<CupertinoPicker>(find.byType(CupertinoPicker));
    picker.scrollController!.jumpToItem(23);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Brug minut'));
    await tester.pumpAndSettle();
    expect(find.text("23'"), findsOneWidget);
    expect(find.text('Ret minut'), findsOneWidget);

    await tester.tap(find.text('Ret minut'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Uden minut'));
    await tester.pumpAndSettle();
    expect(find.text('Tilføj minut (valgfrit)'), findsOneWidget);
    expect(find.text("23'"), findsNothing);
    expect(tester.takeException(), isNull);
  });

  test('event requests omit an unknown minute', () {
    final command = CreateMatchEventCommand(
        eventId: 1, type: MatchEventType.goal, teamId: 1, goalscorerUserId: 2);
    expect(command.toJson().containsKey('minute'), isFalse);
  });
}

Future<void> _open(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final now = DateTime(2026, 1, 1);
  final user = UserDetails(
      id: 1,
      name: 'Owner',
      email: 'owner@example.com',
      isTeamOwner: true,
      roleId: 1,
      createdAt: now,
      updatedAt: now,
      teamDetails: null);
  await tester.pumpWidget(MaterialApp(
    theme: AppTheme.lightTheme,
    locale: const Locale('da'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Builder(
        builder: (context) => Scaffold(
            body: TextButton(
                onPressed: () => showAddMatchEventModal(
                    context,
                    1,
                    const [
                      MatchPlayer(userId: 2, name: 'Alice Jensen'),
                      MatchPlayer(userId: 3, name: 'Bob Hansen'),
                    ],
                    user,
                    () async {}),
                child: const Text('Open')))),
  ));
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}
