import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/component/match/match_events_timeline.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/model/match_event_details.dart';
import 'package:kopa/model/match_event_type.dart';

void main() {
  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    for (final hold in [Duration.zero, const Duration(milliseconds: 800)]) {
      testWidgets('drag reorders in scrolling page on $platform after $hold',
          (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        List<int>? saved;
        await tester.pumpWidget(MaterialApp(
          theme: ThemeData(platform: platform),
          locale: const Locale('da'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(children: [
                const SizedBox(height: 150),
                MatchEventsTimeline(
                  events: List.generate(
                      3,
                      (i) => MatchEventDetails(
                            id: i + 1,
                            eventId: 1,
                            teamId: 1,
                            type: MatchEventType.goal,
                            minute: (i + 1) * 10,
                            goalscorerUserName: 'Player ${i + 1}',
                          )),
                  canAddEvent: false,
                  canReorderEvents: true,
                  onAddEvent: () {},
                  onDeleteEvent: (_) {},
                  onReorderEvents: (ids) async {
                    saved = ids;
                  },
                ),
                const SizedBox(height: 800),
              ]),
            ),
          ),
        ));
        final handle = find.byType(ReorderableDragStartListener).first;
        final start = tester.getTopLeft(handle) + const Offset(3, 24);
        final target = tester
            .getBottomRight(
              find.byKey(const ValueKey('match-event-timeline-3')),
            )
            .dy;
        final gesture = await tester.startGesture(start);
        await tester.pump(hold);
        await gesture.moveBy(const Offset(0, 25));
        await tester.pump();
        await gesture.moveTo(Offset(start.dx, target));
        await tester.pump(const Duration(milliseconds: 500));
        await gesture.up();
        await tester.pumpAndSettle();
        expect(saved, [2, 1, 3]);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
