import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/template/match_detail_template.dart';

void main() {
  testWidgets('attendance segment does not render duplicate section header',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MatchDetailTemplate(
          selectedSegment: MatchDetailSegment.attendance,
          heroCard: SizedBox(height: 1),
          attendanceList: [
            Text('Attending Player'),
          ],
        ),
      ),
    );

    expect(find.text('Tilmeldte'), findsOneWidget);
    expect(find.text('Tilmeldte spillere'), findsNothing);
    expect(find.text('Attending Player'), findsOneWidget);
  });

  testWidgets('match details header scrolls with page content', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MatchDetailTemplate(
          heroCard: const SizedBox(height: 220, child: Text('Hero')),
          overviewWidgets: [
            for (var i = 0; i < 20; i++)
              SizedBox(height: 80, child: Text('Row $i')),
          ],
        ),
      ),
    );

    final header = find.byKey(const ValueKey('match-details-scroll-header'));
    final initialTop = tester.getTopLeft(header).dy;

    await tester.drag(
        find.byType(SingleChildScrollView), const Offset(0, -180));
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(header).dy, lessThan(initialTop));
  });
}
