import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/component/timeline/timeline_item.dart';
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

  testWidgets('attendance action is fixed and absent from the header',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MatchDetailTemplate(
          selectedSegment: MatchDetailSegment.attendance,
          heroCard: const SizedBox(height: 1),
          attendanceList: [
            for (var i = 0; i < 20; i++)
              SizedBox(height: 64, child: Text('Player $i')),
          ],
          attendanceActionBar: const SizedBox(
            key: ValueKey('create-external-player-action-bar'),
            height: 80,
            child: Text('Opret lånespiller'),
          ),
        ),
      ),
    );

    final actionBar =
        find.byKey(const ValueKey('create-external-player-action-bar'));
    expect(
      find.byKey(const ValueKey('add-external-player')),
      findsNothing,
    );
    expect(actionBar, findsOneWidget);

    final initialActionBottom = tester.getRect(actionBar).bottom;
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();

    expect(
      tester.getRect(actionBar).bottom,
      closeTo(initialActionBottom, 0.1),
    );
    expect(
      find.text('Opret lånespiller'),
      findsOneWidget,
    );
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

  testWidgets('prematch events segment shows a disabled timeline preview',
      (tester) async {
    const message =
        'Kampbegivenheder bliver tilgængelige, når kampens resultat er indtastet.';

    Widget buildTemplate(
        {MatchDetailSegment selectedSegment = MatchDetailSegment.overview}) {
      return MaterialApp(
        home: MatchDetailTemplate(
          selectedSegment: selectedSegment,
          onSegmentChanged: (_) {},
          heroCard: const SizedBox(height: 1),
          usePrematchLayout: true,
          timelineTitle: 'Kamp begivenheder',
          timelineSegmentLabel: 'Kamp begivenheder',
          timelinePreview: true,
          timelinePreviewMessage: message,
          timelineItems: const [
            TimelineItem(
              title: 'Kampstart',
              time: "0'",
              icon: Icons.play_arrow,
            ),
          ],
        ),
      );
    }

    await tester.pumpWidget(buildTemplate());

    expect(
      find.byKey(const ValueKey('match-details-segment-overview')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('match-details-segment-attendance')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('match-details-segment-timeline')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('match-details-events-preview-content')),
      findsNothing,
    );

    await tester.pumpWidget(
      buildTemplate(selectedSegment: MatchDetailSegment.timeline),
    );

    expect(find.text('Kamp begivenheder'), findsNWidgets(2));
    expect(find.text(message), findsOneWidget);
    expect(
      find.byKey(const ValueKey('match-details-events-preview-content')),
      findsOneWidget,
    );
    expect(
      tester
          .widget<Opacity>(
            find.byKey(const ValueKey('match-details-events-preview-content')),
          )
          .opacity,
      closeTo(0.38, 0.001),
    );
    expect(find.byType(TimelineItem), findsOneWidget);
  });

  testWidgets('prematch response content sits between the hero and top bar',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MatchDetailTemplate(
          heroCard: const SizedBox(
            key: ValueKey('match-details-hero'),
            height: 1,
          ),
          usePrematchLayout: true,
          attendanceHeader: Container(
            key: const ValueKey('attendance-rsvp-content'),
            height: 38,
          ),
          attendanceList: const [Text('Attending Player')],
          bottomNavigationBar: const SizedBox(
            key: ValueKey('match-details-bottom-navigation'),
            height: 72,
          ),
        ),
      ),
    );

    final responseStatus =
        find.byKey(const ValueKey('attendance-rsvp-content'));
    final attendanceSegment =
        find.byKey(const ValueKey('match-details-segment-attendance'));
    final navigation =
        find.byKey(const ValueKey('match-details-bottom-navigation'));

    expect(
      tester.getTopLeft(responseStatus).dy,
      greaterThan(tester
          .getRect(find.byKey(const ValueKey('match-details-hero')))
          .bottom),
    );
    expect(
      tester.getTopLeft(responseStatus).dy,
      lessThan(tester.getTopLeft(attendanceSegment).dy),
    );
    expect(tester.getSize(navigation).height, 72);

    await tester.pumpWidget(
      MaterialApp(
        home: MatchDetailTemplate(
          selectedSegment: MatchDetailSegment.attendance,
          heroCard: const SizedBox(height: 1),
          usePrematchLayout: true,
          attendanceHeader: Container(
            key: const ValueKey('attendance-rsvp-content'),
            height: 38,
          ),
          attendanceList: const [Text('Attending Player')],
        ),
      ),
    );

    expect(responseStatus, findsOneWidget);
    expect(
      tester.getTopLeft(responseStatus).dy,
      lessThan(tester.getTopLeft(attendanceSegment).dy),
    );
    expect(
      tester.getTopLeft(find.text('Attending Player')).dy,
      greaterThan(tester.getRect(attendanceSegment).bottom),
    );
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
