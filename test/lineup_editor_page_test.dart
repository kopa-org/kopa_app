import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/model/event_attendance_details.dart';
import 'package:kopa/model/external_player_details.dart';
import 'package:kopa/model/match_details.dart';
import 'package:kopa/model/user_details.dart';
import 'package:kopa/page/match/lineup_editor_page.dart';
import 'package:kopa/theme/app_theme.dart';

void main() {
  testWidgets('back closes typed lineup route without a result',
      (tester) async {
    FlutterSecureStorage.setMockInitialValues({'lineupDragHintSeen': 'true'});

    MatchDetails? routeResult;
    var routeCompleted = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return TextButton(
              onPressed: () async {
                routeResult = await Navigator.of(context).push<MatchDetails>(
                  CupertinoPageRoute(
                    builder: (_) => LineupEditorPage(
                      match: _match(),
                      playerCount: 7,
                    ),
                  ),
                );
                routeCompleted = true;
              },
              child: const Text('Open editor'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open editor'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(routeCompleted, isTrue);
    expect(routeResult, isNull);
  });

  testWidgets('newly joined players remain on the bench', (tester) async {
    FlutterSecureStorage.setMockInitialValues({'lineupDragHintSeen': 'true'});
    final now = DateTime(2026, 8, 9, 12);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: LineupEditorPage(
          match: _match(
            attendanceDetailsList: [
              _attendance(
                id: 1,
                user: _user(id: 1, name: 'Alice Jensen', now: now),
                now: now,
              ),
              _attendance(
                id: 2,
                user: _user(id: 2, name: 'Bob Hansen', now: now),
                now: now,
              ),
            ],
          ),
          playerCount: 7,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final benchHeader = find.text('Bænken (2 spillere)');
    expect(benchHeader, findsOneWidget);
    expect(
      tester.getRect(find.text('Alice')).top,
      greaterThan(tester.getRect(benchHeader).top),
    );
    expect(
      tester.getRect(find.text('Bob')).top,
      greaterThan(tester.getRect(benchHeader).top),
    );
  });

  testWidgets('match-only external players start on the bench', (tester) async {
    FlutterSecureStorage.setMockInitialValues({'lineupDragHintSeen': 'true'});
    final now = DateTime(2026, 8, 9, 12);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: LineupEditorPage(
          match: _match(
            externalPlayerDetailsList: [
              ExternalPlayerDetails(
                id: 99,
                eventId: 1,
                name: 'Guest Player',
                createdAt: now,
                updatedAt: now,
              ),
            ],
          ),
          playerCount: 7,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final benchHeader = find.text('Bænken (1 spillere)');
    expect(benchHeader, findsOneWidget);
    expect(
      tester.getRect(find.text('Guest')).top,
      greaterThan(tester.getRect(benchHeader).top),
    );
  });

  testWidgets('dragging a starter to the bench removes them from the field',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    FlutterSecureStorage.setMockInitialValues({'lineupDragHintSeen': 'true'});
    final now = DateTime(2026, 8, 9, 12);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: LineupEditorPage(
          match: _match(
            attendanceDetailsList: [
              _attendance(
                id: 1,
                user: _user(id: 1, name: 'Alice Jensen', now: now),
                now: now,
                lineupSlot: 0,
              ),
            ],
          ),
          playerCount: 7,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final player = find.text('Alice');
    final emptyBench = find.text('Ingen spillere på bænken');
    final gesture = await tester.startGesture(tester.getRect(player).center);
    await tester.pump(const Duration(milliseconds: 600));
    await gesture.moveTo(tester.getRect(emptyBench).center);
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    final benchHeader = find.text('Bænken (1 spillere)');
    expect(benchHeader, findsOneWidget);
    expect(
      tester.getRect(player).top,
      greaterThan(tester.getRect(benchHeader).top),
    );
  });

  testWidgets('dragging a starter onto another starter swaps their slots',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    FlutterSecureStorage.setMockInitialValues({'lineupDragHintSeen': 'true'});
    final now = DateTime(2026, 8, 9, 12);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: LineupEditorPage(
          match: _match(
            attendanceDetailsList: [
              _attendance(
                id: 1,
                user: _user(id: 1, name: 'Alice Jensen', now: now),
                now: now,
                lineupSlot: 0,
              ),
              _attendance(
                id: 2,
                user: _user(id: 2, name: 'Bob Hansen', now: now),
                now: now,
                lineupSlot: 1,
              ),
            ],
          ),
          playerCount: 7,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final alice = find.text('Alice');
    final bob = find.text('Bob');
    final aliceCenter = tester.getRect(alice).center;
    final bobCenter = tester.getRect(bob).center;
    expect(aliceCenter.dy, lessThan(bobCenter.dy));

    final gesture = await tester.startGesture(aliceCenter);
    await tester.pump(const Duration(milliseconds: 600));
    await gesture.moveTo(bobCenter);
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    expect(find.text('Bænken (0 spillere)'), findsOneWidget);
    expect(tester.getRect(find.text('Alice')).top,
        greaterThan(tester.getRect(find.text('Bob')).top));
  });

  testWidgets('warns before leaving after an unsaved lineup edit',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    FlutterSecureStorage.setMockInitialValues({'lineupDragHintSeen': 'true'});
    final now = DateTime(2026, 8, 9, 12);
    MatchDetails? routeResult;
    var routeCompleted = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        locale: const Locale('da'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            return TextButton(
              onPressed: () async {
                routeResult = await Navigator.of(context).push<MatchDetails>(
                  CupertinoPageRoute(
                    builder: (_) => LineupEditorPage(
                      match: _match(
                        attendanceDetailsList: [
                          _attendance(
                            id: 1,
                            user: _user(
                              id: 1,
                              name: 'Alice Jensen',
                              now: now,
                            ),
                            now: now,
                            lineupSlot: 0,
                          ),
                        ],
                      ),
                      playerCount: 7,
                    ),
                  ),
                );
                routeCompleted = true;
              },
              child: const Text('Open editor'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open editor'));
    await tester.pumpAndSettle();

    final player = find.text('Alice');
    final emptyBench = find.text('Ingen spillere på bænken');
    final gesture = await tester.startGesture(tester.getRect(player).center);
    await tester.pump(const Duration(milliseconds: 600));
    await gesture.moveTo(tester.getRect(emptyBench).center);
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('Du har ikke gemt holdopstillingen'), findsOneWidget);
    expect(find.byKey(const ValueKey('lineup-unsaved-save')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('lineup-unsaved-discard')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('lineup-unsaved-discard')));
    await tester.pumpAndSettle();

    expect(routeCompleted, isTrue);
    expect(routeResult, isNull);
    expect(tester.takeException(), isNull);
  });
}

MatchDetails _match({
  List<EventAttendanceDetails>? attendanceDetailsList,
  List<ExternalPlayerDetails>? externalPlayerDetailsList,
}) {
  final now = DateTime(2026, 8, 9, 12);
  return MatchDetails(
    id: 1,
    homeTeam: 'Kopa IF',
    awayTeam: 'Fremad',
    date: now.add(const Duration(days: 1)),
    location: 'Kopa Stadion',
    createdAt: now,
    updatedAt: now,
    attendanceDetailsList: attendanceDetailsList ?? const [],
    externalPlayerDetailsList: externalPlayerDetailsList ?? const [],
  );
}

EventAttendanceDetails _attendance({
  required int id,
  required UserDetails user,
  required DateTime now,
  int? lineupSlot,
}) {
  return EventAttendanceDetails(
    id: id,
    userDetails: user,
    isAttending: true,
    isSelected: true,
    lineupSlot: lineupSlot,
    createdAt: now,
    updatedAt: now,
  );
}

UserDetails _user({
  required int id,
  required String name,
  required DateTime now,
}) {
  return UserDetails(
    id: id,
    name: name,
    email: 'user$id@example.com',
    isTeamOwner: false,
    roleId: 3,
    createdAt: now,
    updatedAt: now,
    teamDetails: null,
  );
}
