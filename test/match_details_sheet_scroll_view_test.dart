import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/component/match/match_details_sheet_scroll_view.dart';
import 'package:kopa/theme/app_colors.dart';

void main() {
  testWidgets('receding header never paints over sheet content',
      (tester) async {
    final boundaryKey = GlobalKey();
    await tester.pumpWidget(RepaintBoundary(key: boundaryKey, child: _app()));
    final position =
        tester.state<ScrollableState>(find.byType(Scrollable)).position;
    position.jumpTo(100);
    await tester.pump();
    final sheet =
        tester.getRect(find.byKey(const ValueKey('match-details-body-sheet')));
    final boundary = boundaryKey.currentContext!.findRenderObject()!
        as RenderRepaintBoundary;
    await tester.runAsync(() async {
      final image = await boundary.toImage();
      final bytes =
          (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
      final pixel =
          ((sheet.top + 40).toInt() * image.width + image.width ~/ 2) * 4;
      final actualColor = Color.fromARGB(
          bytes.getUint8(pixel + 3),
          bytes.getUint8(pixel),
          bytes.getUint8(pixel + 1),
          bytes.getUint8(pixel + 2));
      expect(actualColor, AppColors.light.background);
      image.dispose();
    });
  });
  for (final bodyHeight in [80.0, 1200.0]) {
    testWidgets('sheet rises over the header with $bodyHeight px of content',
        (tester) async {
      await tester.pumpWidget(_app(bodyHeight: bodyHeight));
      final sheet = find.byKey(const ValueKey('match-details-body-sheet'));
      final header = find.byKey(const ValueKey('test-header'));
      final initialSheet = tester.getRect(sheet);
      final initialHeader = tester.getRect(header);
      expect(tester.widget<ClipRRect>(sheet).borderRadius,
          const BorderRadius.vertical(top: Radius.circular(28)));

      await tester.drag(
          find.byKey(const ValueKey('match-details-sheet-scroll')),
          const Offset(0, -100));
      await tester.pumpAndSettle();
      final raisedSheet = tester.getRect(sheet);
      final recedingHeader = tester.getRect(header);
      expect(raisedSheet.top, lessThan(initialSheet.top));
      expect(recedingHeader.top, lessThan(initialHeader.top));
      expect(initialHeader.top - recedingHeader.top,
          lessThan(initialSheet.top - raisedSheet.top));
      expect(
          tester
              .widget<Opacity>(
                  find.byKey(const ValueKey('match-details-header-fade')))
              .opacity,
          lessThan(1));

      final position =
          tester.state<ScrollableState>(find.byType(Scrollable)).position;
      position.jumpTo(position.maxScrollExtent);
      await tester.pump();
      expect(tester.getRect(sheet).top, lessThanOrEqualTo(0));
      position.jumpTo(0);
      await tester.pump();
      expect(tester.getRect(sheet), initialSheet);
      expect(tester.getRect(header), initialHeader);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('reduced motion keeps scrolling without scale, fade or parallax',
      (tester) async {
    await tester.pumpWidget(_app(reduceMotion: true));
    final header = find.byKey(const ValueKey('test-header'));
    final sheet = find.byKey(const ValueKey('match-details-body-sheet'));
    final initialHeader = tester.getRect(header);
    final initialSheet = tester.getRect(sheet);
    await tester.drag(find.byKey(const ValueKey('match-details-sheet-scroll')),
        const Offset(0, -100));
    await tester.pumpAndSettle();
    expect(initialHeader.top - tester.getRect(header).top,
        closeTo(initialSheet.top - tester.getRect(sheet).top, 0.1));
    expect(
        tester
            .widget<Opacity>(
                find.byKey(const ValueKey('match-details-header-fade')))
            .opacity,
        1);
    expect(tester.takeException(), isNull);
  });

  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    testWidgets('$platform uses one scrollable and preserves pull to refresh',
        (tester) async {
      var refreshes = 0;
      await tester.pumpWidget(_app(
        platform: platform,
        onRefresh: () async {
          refreshes++;
        },
      ));
      await tester.pumpAndSettle();
      expect(
          Theme.of(tester.element(find.byType(MatchDetailsSheetScrollView)))
              .platform,
          platform);
      expect(find.byType(Scrollable), findsOneWidget);
      expect(find.byType(CupertinoSliverRefreshControl, skipOffstage: false),
          platform == TargetPlatform.iOS ? findsOneWidget : findsNothing);
      await tester.timedDrag(
          find.byKey(const ValueKey('match-details-sheet-scroll')),
          const Offset(0, 350),
          const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(refreshes, 1);
      expect(tester.takeException(), isNull);
    });
  }
}

Widget _app({
  double bodyHeight = 1200,
  bool reduceMotion = false,
  TargetPlatform platform = TargetPlatform.android,
  Future<void> Function()? onRefresh,
}) =>
    MaterialApp(
      theme: ThemeData(platform: platform),
      home: Scaffold(
          body: MediaQuery(
        data: MediaQueryData(disableAnimations: reduceMotion),
        child: MatchDetailsSheetScrollView(
          onRefresh: onRefresh,
          header: const ColoredBox(
              color: Colors.red,
              child: SizedBox(
                  key: ValueKey('test-header'),
                  height: 220,
                  child: Text('Match header'))),
          body: SizedBox(height: bodyHeight, child: const Text('Match body')),
        ),
      )),
    );
