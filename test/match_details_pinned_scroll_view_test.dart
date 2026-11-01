import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopa/component/match/match_details_pinned_scroll_view.dart';

void main() {
  for (final bodyHeight in [80.0, 1200.0]) {
    testWidgets('header shrinks then pins with $bodyHeight px of content',
        (tester) async {
      final collapses = <double>[];
      await tester
          .pumpWidget(_app(bodyHeight: bodyHeight, onCollapse: collapses.add));
      final header = find.byKey(const ValueKey('test-header'));
      expect(tester.getSize(header).height, 220);
      expect(collapses.last, 0);

      await tester.drag(find.byKey(const ValueKey('match-details-scroll')),
          const Offset(0, -60));
      await tester.pumpAndSettle();
      expect(tester.getSize(header).height, closeTo(160, 0.01));
      expect(tester.getTopLeft(header).dy, 0);
      expect(collapses.last, closeTo(.5, 0.01));

      final position =
          tester.state<ScrollableState>(find.byType(Scrollable)).position;
      position.jumpTo(position.maxScrollExtent);
      await tester.pump();
      expect(tester.getSize(header).height, 100);
      expect(tester.getTopLeft(header).dy, 0);
      expect(collapses.last, 1);

      position.jumpTo(0);
      await tester.pump();
      expect(tester.getSize(header).height, 220);
      expect(tester.takeException(), isNull);
    });
  }

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
      expect(find.byType(Scrollable), findsOneWidget);
      expect(find.byType(CupertinoSliverRefreshControl, skipOffstage: false),
          platform == TargetPlatform.iOS ? findsOneWidget : findsNothing);
      await tester.timedDrag(find.byKey(const ValueKey('match-details-scroll')),
          const Offset(0, 350), const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(refreshes, 1);
      expect(tester.takeException(), isNull);
    });
  }
}

Widget _app({
  double bodyHeight = 1200,
  TargetPlatform platform = TargetPlatform.android,
  Future<void> Function()? onRefresh,
  ValueChanged<double>? onCollapse,
}) =>
    MaterialApp(
      theme: ThemeData(platform: platform),
      home: Scaffold(
        body: MatchDetailsPinnedScrollView(
          onRefresh: onRefresh,
          expandedHeaderExtent: 220,
          collapsedHeaderExtent: 100,
          header: (context, collapse) {
            onCollapse?.call(collapse);
            return const SizedBox.expand(
              key: ValueKey('test-header'),
              child: ColoredBox(color: Colors.red),
            );
          },
          body: SizedBox(height: bodyHeight, child: const Text('Match body')),
        ),
      ),
    );
