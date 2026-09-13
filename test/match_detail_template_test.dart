import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/template/match_detail_template.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';

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

  testWidgets('match details segments use the underline design',
      (tester) async {
    MatchDetailSegment? selected;

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: <ThemeExtension<dynamic>>[
            AppColors.light,
            AppTextStyles.light,
          ],
        ),
        home: MatchDetailTemplate(
          heroCard: const SizedBox(height: 1),
          showTimelineSegment: false,
          onSegmentChanged: (segment) => selected = segment,
        ),
      ),
    );

    final selectedIndicator = tester.widget<AnimatedContainer>(
      find.byKey(
        const ValueKey('match-details-segment-overview-indicator'),
      ),
    );
    final selectedDecoration = selectedIndicator.decoration! as BoxDecoration;
    expect(selectedDecoration.color, const Color(0xFF105230));
    expect(
      tester
          .getSize(
            find.byKey(const ValueKey('match-details-segment-overview')),
          )
          .height,
      30,
    );

    final unselectedIndicator = tester.widget<AnimatedContainer>(
      find.byKey(
        const ValueKey('match-details-segment-attendance-indicator'),
      ),
    );
    final unselectedDecoration =
        unselectedIndicator.decoration! as BoxDecoration;
    expect(unselectedDecoration.color, Colors.transparent);

    await tester.tap(
      find.byKey(const ValueKey('match-details-segment-attendance')),
    );

    expect(selected, MatchDetailSegment.attendance);
  });

  testWidgets('prematch response status sits above content and nav',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MatchDetailTemplate(
          heroCard: const SizedBox(height: 1),
          usePrematchLayout: true,
          inlineResponseStatus: Container(
            key: const ValueKey('inline-response-status'),
            height: 38,
          ),
          infoRows: const [SizedBox(height: 20)],
          bottomNavigationBar: const SizedBox(
            key: ValueKey('match-details-bottom-navigation'),
            height: 72,
          ),
        ),
      ),
    );

    final responseStatus = find.byKey(const ValueKey('inline-response-status'));
    final practicalTitle = find.text('Praktisk information');
    final navigation =
        find.byKey(const ValueKey('match-details-bottom-navigation'));

    expect(
      tester.getTopLeft(responseStatus).dy,
      lessThan(tester.getTopLeft(practicalTitle).dy),
    );
    expect(tester.getSize(navigation).height, 72);
  });

  testWidgets('match details layout supports the iOS refresh scaffold',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(platform: TargetPlatform.iOS),
        home: MatchDetailTemplate(
          heroCard: const SizedBox(height: 1),
          onRefresh: () async {},
          usePrematchLayout: true,
          stickyActionBar: const SizedBox(height: 126),
          bottomNavigationBar: const SizedBox(height: 72),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
