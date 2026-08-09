import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/model/match_details.dart';
import 'package:kopa/page/match/lineup_editor_page.dart';

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
}

MatchDetails _match() {
  final now = DateTime(2026, 8, 9, 12);

  return MatchDetails(
    id: 1,
    homeTeam: 'Kopa IF',
    awayTeam: 'Fremad',
    date: now.add(const Duration(days: 1)),
    location: 'Kopa Stadion',
    createdAt: now,
    updatedAt: now,
    attendanceDetailsList: const [],
  );
}
