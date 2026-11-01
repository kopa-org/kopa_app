import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kopa/theme/app_colors.dart';

/// Scrolls [body] under a header that shrinks, then stays pinned at the top.
class MatchDetailsPinnedScrollView extends StatelessWidget {
  /// Builds the header; `collapse` runs from 0 (expanded) to 1 (pinned).
  final Widget Function(BuildContext context, double collapse) header;
  final double expandedHeaderExtent;
  final double collapsedHeaderExtent;
  final Widget body;
  final Future<void> Function()? onRefresh;

  const MatchDetailsPinnedScrollView({
    super.key,
    required this.header,
    required this.expandedHeaderExtent,
    required this.collapsedHeaderExtent,
    required this.body,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    return ColoredBox(
      color: AppColors.of(context).background,
      child: LayoutBuilder(builder: (context, viewport) {
        final scrollView = CustomScrollView(
          key: const ValueKey('match-details-scroll'),
          physics: AlwaysScrollableScrollPhysics(
            parent: isIOS
                ? const BouncingScrollPhysics()
                : const ClampingScrollPhysics(),
          ),
          slivers: [
            if (isIOS && onRefresh != null)
              CupertinoSliverRefreshControl(onRefresh: onRefresh),
            SliverPersistentHeader(
              pinned: true,
              delegate: _PinnedHeaderDelegate(
                builder: header,
                minExtent: collapsedHeaderExtent,
                maxExtent: expandedHeaderExtent,
              ),
            ),
            SliverToBoxAdapter(
              child: ConstrainedBox(
                // Short tabs can still scroll far enough to fully collapse.
                constraints: BoxConstraints(
                  minHeight: (viewport.maxHeight - collapsedHeaderExtent)
                      .clamp(0.0, double.infinity),
                ),
                child: body,
              ),
            ),
          ],
        );
        return !isIOS && onRefresh != null
            ? RefreshIndicator(
                edgeOffset: MediaQuery.paddingOf(context).top,
                onRefresh: onRefresh!,
                child: scrollView,
              )
            : scrollView;
      }),
    );
  }
}

class _PinnedHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget Function(BuildContext context, double collapse) builder;
  @override
  final double minExtent;
  @override
  final double maxExtent;

  const _PinnedHeaderDelegate({
    required this.builder,
    required this.minExtent,
    required this.maxExtent,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final range = maxExtent - minExtent;
    final collapse = range <= 0 ? 1.0 : (shrinkOffset / range).clamp(0.0, 1.0);
    return builder(context, collapse);
  }

  // The header shows live match data, so it follows every template rebuild.
  @override
  bool shouldRebuild(covariant _PinnedHeaderDelegate oldDelegate) => true;
}
