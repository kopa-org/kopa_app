import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/component/home/home_carousel_indicator.dart';
import 'package:kopa/theme/app_theme.dart';

void main() {
  for (final width in [80.0, 320.0, 390.0]) {
    testWidgets('100 events stay bounded at width $width', (tester) async {
      final controller = PageController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(_app(controller, count: 100, width: width));
      final strip = find.byKey(const ValueKey('indicator-bounds'));
      final active =
          find.byKey(const ValueKey('home-carousel-active-indicator'));
      for (final index in [0, 1, 49, 98, 99]) {
        controller.jumpToPage(index);
        await tester.pumpAndSettle();
        final rect = tester.getRect(active);
        final bounds = tester.getRect(strip);
        expect(rect.left, greaterThanOrEqualTo(bounds.left));
        expect(rect.right, lessThanOrEqualTo(bounds.right));
        expect(find.descendant(of: strip, matching: find.byType(ClipRect)),
            findsNothing);
        for (final element in find
            .descendant(of: strip, matching: find.byType(Container))
            .evaluate()) {
          final dot = tester.getRect(find.byWidget(element.widget));
          expect(dot.left, greaterThanOrEqualTo(bounds.left));
          expect(dot.right, lessThanOrEqualTo(bounds.right));
          expect(dot.width, closeTo(dot.height, 0.001));
          if ((dot.center.dx - rect.center.dx).abs() > 0.01) {
            final gap = dot.center.dx < rect.center.dx
                ? rect.left - dot.right
                : dot.left - rect.right;
            expect(gap, greaterThanOrEqualTo(6));
          }
        }
        expect(
            find
                .descendant(of: strip, matching: find.byType(Container))
                .evaluate()
                .length,
            lessThanOrEqualTo(11));
        expect(tester.takeException(), isNull);
      }
      // A refreshed event list may be much shorter than the old page position.
      await tester.pumpWidget(_app(controller, count: 3, width: width));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byKey(const ValueKey('home-carousel-active-indicator')),
          findsOneWidget);
    });
  }

  testWidgets('marker moves continuously during forward and backward paging',
      (tester) async {
    final controller = PageController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(_app(controller, count: 20, width: 320));
    final active = find.byKey(const ValueKey('home-carousel-active-indicator'));
    final initial = tester.getRect(active);
    expect(initial.size, const Size(18, 6));
    final forward = controller.animateToPage(1,
        duration: const Duration(milliseconds: 300), curve: Curves.linear);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    final intermediate = tester.getRect(active);
    expect(intermediate.center.dx, greaterThan(initial.center.dx));
    expect(intermediate.width, lessThan(initial.width));
    await tester.pump(const Duration(milliseconds: 50));
    expect(tester.getRect(active).width, closeTo(6, 0.01));
    await tester.pumpAndSettle();
    await forward;
    final finalRect = tester.getRect(active);
    expect(intermediate.center.dx, lessThan(finalRect.center.dx));
    expect(finalRect.size, const Size(18, 6));
    expect(intermediate.height, initial.height);
    final backward = controller.animateToPage(0,
        duration: const Duration(milliseconds: 300), curve: Curves.linear);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.getRect(active).center.dx, lessThan(finalRect.center.dx));
    expect(tester.getRect(active).center.dx, greaterThan(initial.center.dx));
    await tester.pumpAndSettle();
    await backward;
    expect(tester.getRect(active), initial);
  });

  testWidgets('edge dots remain whole while the long strip moves',
      (tester) async {
    final controller = PageController(initialPage: 49);
    addTearDown(controller.dispose);
    await tester.pumpWidget(_app(controller, count: 100, width: 80));
    final strip = find.byKey(const ValueKey('indicator-bounds'));
    final animation = controller.animateToPage(50,
        duration: const Duration(milliseconds: 300), curve: Curves.linear);
    await tester.pump();
    for (var frame = 0; frame < 3; frame++) {
      await tester.pump(const Duration(milliseconds: 75));
      final bounds = tester.getRect(strip);
      for (final element in find
          .descendant(of: strip, matching: find.byType(Container))
          .evaluate()) {
        final dot = tester.getRect(find.byWidget(element.widget));
        expect(dot.left, greaterThanOrEqualTo(bounds.left));
        expect(dot.right, lessThanOrEqualTo(bounds.right));
        expect(dot.width, closeTo(dot.height, 0.001));
      }
      expect(tester.takeException(), isNull);
    }
    await tester.pumpAndSettle();
    await animation;
  });
}

Widget _app(PageController controller,
        {required int count, required double width}) =>
    MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: width,
            child: Column(
              children: [
                SizedBox(
                  height: 100,
                  child: PageView.builder(
                    controller: controller,
                    itemCount: count,
                    itemBuilder: (_, index) => Text('Event $index'),
                  ),
                ),
                HomeCarouselIndicator(
                  key: const ValueKey('indicator-bounds'),
                  count: count,
                  controller: controller,
                ),
              ],
            ),
          ),
        ),
      ),
    );
