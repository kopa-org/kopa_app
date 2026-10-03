import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/component/match/match_quick_actions_fab.dart';
import 'package:kopa/l10n/app_localizations.dart';
import 'package:kopa/template/match_detail_template.dart';
import 'package:kopa/theme/app_theme.dart';

void main() {
  for (final platform in [TargetPlatform.iOS, TargetPlatform.android]) {
    for (final width in [320.0, 390.0]) {
      for (final parentNavigation in [false, true]) {
        testWidgets(
            '$platform $width parent nav=$parentNavigation keeps all actions tappable',
            (tester) async {
          tester.view.physicalSize = Size(width, 844);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final actions = <String>[];
          await tester.pumpWidget(_app(
            platform: platform,
            parentNavigation: parentNavigation,
            fab: MatchQuickActionsFab(
              matchId: 42,
              onPoll: () => actions.add('motm'),
              onResult: () => actions.add('result'),
              onExternalPlayers: () => actions.add('external-players'),
            ),
          ));
          await tester.pumpAndSettle();
          final mainFab = find.byKey(const ValueKey('match-quick-actions-fab'));
          final originalRect = tester.getRect(mainFab);
          final navigationTop =
              tester.getRect(find.byKey(const ValueKey('navigation'))).top;
          expect(originalRect.bottom, lessThan(navigationTop));

          for (final action in ['motm', 'result', 'external-players']) {
            await tester.tap(mainFab);
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 80));
            final movingRects = [
              for (final name in ['motm', 'result', 'external-players'])
                tester.getRect(find.byKey(ValueKey('match-fab-$name'))),
            ];
            await tester.pumpAndSettle();
            final labels = ['MOTM', 'Resultat', 'Tilføj ekst. spiller'];
            final actionRects = [
              for (final name in ['motm', 'result', 'external-players'])
                tester.getRect(find.byKey(ValueKey('match-fab-$name'))),
            ];
            for (var i = 0; i < labels.length; i++) {
              expect(find.text(labels[i]).hitTestable(), findsOneWidget);
              expect(actionRects[i].bottom, lessThan(originalRect.top));
              // Vertical actions keep their size and orientation as they rise.
              expect(movingRects[i].size, actionRects[i].size);
              expect(movingRects[i].right, closeTo(actionRects[i].right, 0.01));
              expect(movingRects[i].top, greaterThan(actionRects[i].top));
              if (i > 0) {
                expect(
                    actionRects[i].top, greaterThan(actionRects[i - 1].bottom));
              }
            }
            expect(
                actionRects.last.width, greaterThan(actionRects.first.width));
            expect(actionRects.last.width, greaterThan(actionRects[1].width));
            final actionFinder = find.byKey(ValueKey('match-fab-$action'));
            final rect = tester.getRect(actionFinder);
            expect(rect.left, greaterThanOrEqualTo(0));
            expect(rect.right, lessThanOrEqualTo(width));
            expect(rect.bottom, lessThan(navigationTop));
            final label =
                labels[['motm', 'result', 'external-players'].indexOf(action)];
            await tester.tap(find.text(label));
            await tester.pumpAndSettle();
            expect(actions.last, action);
            // Selecting an action collapses the menu so it can open again.
            expect(tester.getRect(mainFab), originalRect);
          }
          expect(actions, ['motm', 'result', 'external-players']);
          await tester.drag(
              find.byKey(const ValueKey('match-details-sheet-scroll')),
              const Offset(0, -160));
          await tester.pumpAndSettle();
          expect(tester.getRect(mainFab), originalRect);
          expect(tester.takeException(), isNull);
        });
      }
    }
  }

  testWidgets('existing poll and score expose edit labels', (tester) async {
    await tester.pumpWidget(_app(
        fab: MatchQuickActionsFab(
      matchId: 42,
      hasPoll: true,
      hasFinalScore: true,
      onPoll: () {},
      onResult: () {},
      onExternalPlayers: () {},
    )));
    await tester.tap(find.byKey(const ValueKey('match-quick-actions-fab')));
    await tester.pumpAndSettle();
    expect(
        tester
            .widget<FloatingActionButton>(
                find.byKey(const ValueKey('match-fab-motm')))
            .tooltip,
        'Kampens spiller: rediger afstemning');
    expect(
        tester
            .widget<FloatingActionButton>(
                find.byKey(const ValueKey('match-fab-result')))
            .tooltip,
        'Rediger kampresultat');
  });

  testWidgets(
      'unavailable actions cannot dispatch while other actions remain usable',
      (tester) async {
    var results = 0;
    await tester.pumpWidget(_app(
        fab: MatchQuickActionsFab(
      matchId: 42,
      onPoll: null,
      onResult: () => results++,
      onExternalPlayers: null,
    )));
    await tester.tap(find.byKey(const ValueKey('match-quick-actions-fab')));
    await tester.pumpAndSettle();
    expect(
        tester
            .widget<FloatingActionButton>(
                find.byKey(const ValueKey('match-fab-motm')))
            .onPressed,
        isNull);
    expect(
        tester
            .widget<FloatingActionButton>(
                find.byKey(const ValueKey('match-fab-external-players')))
            .onPressed,
        isNull);
    await tester.tap(find.byKey(const ValueKey('match-fab-result')));
    await tester.pumpAndSettle();
    expect(results, 1);
  });
}

Widget _app({
  required Widget fab,
  TargetPlatform platform = TargetPlatform.android,
  bool parentNavigation = false,
}) =>
    MaterialApp(
      theme: AppTheme.lightTheme.copyWith(platform: platform),
      locale: const Locale('da'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        extendBody: parentNavigation,
        bottomNavigationBar: parentNavigation
            ? const SizedBox(key: ValueKey('navigation'), height: 100)
            : null,
        body: Builder(builder: (context) {
          final template = MatchDetailTemplate(
            useDarkMatchHeader: true,
            useParentBottomNavigationBar: parentNavigation,
            heroCard: const SizedBox(height: 160),
            overviewWidgets: const [SizedBox(height: 1200)],
            floatingActionButton: fab,
            bottomNavigationBar: parentNavigation
                ? null
                : const SizedBox(key: ValueKey('navigation'), height: 88),
          );
          return template;
        }),
      ),
    );
