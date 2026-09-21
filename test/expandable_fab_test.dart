import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/component/button/expandable_fab.dart';

void main() {
  testWidgets('expands actions and forwards action presses', (tester) async {
    var matchPressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          floatingActionButton: ExpandableFab(
            distance: 88,
            openButtonKey: const ValueKey('open-fab'),
            children: [
              FloatingActionButton.small(
                key: const ValueKey('match-action'),
                onPressed: () => matchPressed = true,
                child: const Icon(Icons.sports_soccer),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('open-fab')));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.close), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('match-action')));
    expect(matchPressed, isTrue);
  });
}
