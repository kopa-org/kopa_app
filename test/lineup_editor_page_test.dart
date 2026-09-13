import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/model/event_attendance_details.dart';
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
}

MatchDetails _match({List<EventAttendanceDetails>? attendanceDetailsList}) {
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
