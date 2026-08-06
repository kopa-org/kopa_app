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
}
