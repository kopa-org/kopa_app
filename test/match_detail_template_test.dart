import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/component/card/kopa_card.dart';
import 'package:kopa/component/card/match_hero_card.dart';
import 'package:kopa/component/timeline/timeline_item.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/model/match_details.dart';
import 'package:kopa/template/match_detail_template.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';

void main() {
  for (final darkHeader in [false, true]) {
    for (final segment in MatchDetailSegment.values) {
      testWidgets('RSVP only on overview: dark=$darkHeader segment=$segment',
          (tester) async {
        await tester.pumpWidget(MaterialApp(
          home: MatchDetailTemplate(
            heroCard: const SizedBox(height: 1),
            useDarkMatchHeader: darkHeader,
            attendanceHeaderInBody: true,
            selectedSegment: segment,
            attendanceHeader: const Text('RSVP controls'),
            attendanceList: const [Text('Attending player')],
          ),
        ));
        expect(
            find.text('RSVP controls'),
            segment == MatchDetailSegment.overview
                ? findsOneWidget
                : findsNothing);
        expect(tester.takeException(), isNull);
      });
    }
  }

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
          useDarkMatchHeader: true,
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

    await tester.drag(find.byKey(const ValueKey('match-details-sheet-scroll')),
        const Offset(0, -180));
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
    expect(selectedDecoration.color, AppColors.light.successForeground);
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

  testWidgets('match header uses the dark Figma surface and leaves body light',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: <ThemeExtension<dynamic>>[
            AppColors.light,
            AppTextStyles.light,
          ],
        ),
        home: MatchDetailTemplate(
          useDarkMatchHeader: true,
          pageTitle: 'Kampdag',
          heroCard: const SizedBox(height: 120, child: Text('Match hero')),
          overviewWidgets: const [Text('Existing body content')],
          showTimelineSegment: false,
        ),
      ),
    );

    final header = tester.widget<ColoredBox>(
      find.byKey(const ValueKey('match-details-dark-header')),
    );
    final contentBackground = tester.widget<ColoredBox>(
      find.byKey(const ValueKey('match-details-content-background')),
    );
    final segmentControl = tester.widget<Container>(
      find.byKey(const ValueKey('match-details-dark-segment-control')),
    );
    final overviewSurface = tester.widget<Container>(
      find.byKey(const ValueKey('match-details-segment-overview-surface')),
    );
    final overviewDecoration = overviewSurface.decoration! as BoxDecoration;

    expect(header.color, AppColors.matchDetailsHeader);
    expect(
      tester
          .getSize(find.byKey(const ValueKey('match-details-dark-header')))
          .width,
      tester.getSize(find.byType(Scaffold)).width,
    );
    expect(contentBackground.color, AppColors.light.background);
    expect(
      (segmentControl.decoration! as BoxDecoration).color,
      AppColors.matchDetailsHeaderTrack,
    );
    expect(overviewDecoration.color, Colors.white);
    expect(find.text('Existing body content'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('result action sits below the dark header before practical info',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: <ThemeExtension<dynamic>>[
            AppColors.light,
            AppTextStyles.light,
          ],
        ),
        home: MatchDetailTemplate(
          useDarkMatchHeader: true,
          usePrematchLayout: true,
          heroCard: const SizedBox(height: 120, child: Text('Match hero')),
          belowHeaderAction: const SizedBox(
            key: ValueKey('match-register-result-action'),
            height: 48,
            child: Text('Register match result'),
          ),
          infoRows: const [Text('Match venue')],
          showTimelineSegment: false,
        ),
      ),
    );

    final headerRect = tester.getRect(
      find.byKey(const ValueKey('match-details-dark-header')),
    );
    final actionRect = tester.getRect(
      find.byKey(const ValueKey('match-register-result-action')),
    );
    final practicalInfoRect = tester.getRect(
      find.text('Praktisk information'),
    );

    expect(actionRect.top, greaterThanOrEqualTo(headerRect.bottom));
    expect(practicalInfoRect.top, greaterThan(actionRect.bottom));
  });

  testWidgets('match hero uses white team labels on the dark header',
      (tester) async {
    final kickoff = DateTime(2026, 8, 17, 20);
    final match = MatchDetails(
      id: 1,
      homeTeam: 'Kopa IF',
      awayTeam: 'Fremad',
      date: kickoff,
      location: 'Kopa Stadion',
      createdAt: kickoff,
      updatedAt: kickoff,
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('da'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ThemeData(
          extensions: <ThemeExtension<dynamic>>[
            AppColors.light,
            AppTextStyles.light,
          ],
        ),
        home: Scaffold(
          body: MatchHeroCard(
            match: match,
            darkHeader: true,
            animateCard: false,
          ),
        ),
      ),
    );

    final card = tester.widget<KopaCard>(find.byType(KopaCard));
    final homeTeam = tester.widget<Text>(find.text('Kopa IF'));

    expect(card.color, AppColors.matchDetailsHeader);
    expect(homeTeam.style!.color, Colors.white);
    expect(tester.takeException(), isNull);
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
          useDarkMatchHeader: true,
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
          useDarkMatchHeader: true,
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

    expect(responseStatus, findsNothing);
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
