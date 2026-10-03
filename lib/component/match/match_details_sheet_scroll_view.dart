import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kopa/theme/app_colors.dart';

/// A rounded content sheet that rises over a receding match header.
class MatchDetailsSheetScrollView extends StatelessWidget {
  final Widget header;
  final Widget body;
  final Future<void> Function()? onRefresh;
  final Color headerBackgroundColor;

  const MatchDetailsSheetScrollView({
    super.key,
    required this.header,
    required this.body,
    this.onRefresh,
    this.headerBackgroundColor = AppColors.matchDetailsHeader,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    return ColoredBox(
      color: headerBackgroundColor,
      child: LayoutBuilder(builder: (context, viewport) {
        final scrollView = CustomScrollView(
          key: const ValueKey('match-details-sheet-scroll'),
          physics: AlwaysScrollableScrollPhysics(
            parent: isIOS
                ? const BouncingScrollPhysics()
                : const ClampingScrollPhysics(),
          ),
          slivers: [
            if (isIOS && onRefresh != null)
              CupertinoSliverRefreshControl(onRefresh: onRefresh),
            SliverLayoutBuilder(builder: (context, constraints) {
              final offset =
                  constraints.scrollOffset.clamp(0.0, double.infinity);
              final distance = (constraints.viewportMainAxisExtent * 0.35)
                  .clamp(1.0, double.infinity);
              final progress = (offset / distance).clamp(0.0, 1.0);
              return SliverToBoxAdapter(
                child: ClipRect(
                  child: IgnorePointer(
                    ignoring: progress == 1,
                    child: ExcludeSemantics(
                      excluding: progress == 1,
                      child: Transform.translate(
                        key: const ValueKey('match-details-header-parallax'),
                        offset: Offset(0, reduceMotion ? 0 : offset * 0.4),
                        child: Transform.scale(
                          key: const ValueKey('match-details-header-recede'),
                          scale: reduceMotion ? 1 : 1 - progress * 0.06,
                          alignment: Alignment.topCenter,
                          child: Opacity(
                            key: const ValueKey('match-details-header-fade'),
                            opacity: reduceMotion ? 1 : 1 - progress * 0.45,
                            child: header,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
            SliverToBoxAdapter(
              child: ClipRRect(
                key: const ValueKey('match-details-body-sheet'),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
                child: ColoredBox(
                  color: colors.background,
                  child: ConstrainedBox(
                    // Short tabs can still raise the sheet over the whole header.
                    constraints: BoxConstraints(minHeight: viewport.maxHeight),
                    child: body,
                  ),
                ),
              ),
            ),
          ],
        );
        return !isIOS && onRefresh != null
            ? RefreshIndicator(onRefresh: onRefresh!, child: scrollView)
            : scrollView;
      }),
    );
  }
}
