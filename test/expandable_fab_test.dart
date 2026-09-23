import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/component/button/expandable_fab.dart';
import 'package:kopa/component/scaffold/page_scaffold.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';

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

  testWidgets('iOS tab FAB keeps both expanded actions tappable',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var matchPresses = 0;
    var trainingPresses = 0;
    const openKey = ValueKey('ios-open-fab');
    const matchKey = ValueKey('ios-match-action');
    const trainingKey = ValueKey('ios-training-action');
    const navigationKey = ValueKey('ios-tab-navigation');

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          platform: TargetPlatform.iOS,
          extensions: <ThemeExtension<dynamic>>[
            AppColors.light,
            AppTextStyles.light,
          ],
        ),
        home: Scaffold(
          extendBody: true,
          body: PageScaffold.tab(
            title: 'Kampprogram',
            body: const SizedBox.expand(),
            floatingActionButton: ExpandableFab(
              distance: 104,
              openButtonKey: openKey,
              heroTag: 'ios-open-fab',
              children: [
                FloatingActionButton(
                  key: matchKey,
                  heroTag: 'ios-match-action',
                  onPressed: () => matchPresses++,
                  child: const Icon(Icons.sports_soccer),
                ),
                FloatingActionButton(
                  key: trainingKey,
                  heroTag: 'ios-training-action',
                  onPressed: () => trainingPresses++,
                  child: const Icon(Icons.fitness_center),
                ),
              ],
            ),
          ),
          bottomNavigationBar: const SizedBox(
            key: navigationKey,
            height: 100,
          ),
        ),
      ),
    );

    final navigationTop = tester.getRect(find.byKey(navigationKey)).top;
    final openRect = tester.getRect(find.byKey(openKey));
    expect(openRect.bottom, lessThanOrEqualTo(navigationTop));
    expect(
      openRect.right,
      lessThanOrEqualTo(
        tester.view.physicalSize.width / tester.view.devicePixelRatio,
      ),
    );

    await tester.tapAt(openRect.center);
    await tester.pumpAndSettle();

    final matchCenter = tester.getRect(find.byKey(matchKey)).center;
    final trainingCenter = tester.getRect(find.byKey(trainingKey)).center;
    expect(matchCenter.dx, lessThan(openRect.left));
    expect(trainingCenter.dy, lessThan(openRect.top));
    await tester.tapAt(matchCenter);
    await tester.tapAt(trainingCenter);

    expect(matchPresses, 1);
    expect(trainingPresses, 1);
  });
}
