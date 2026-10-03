import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:kopa/theme/app_colors.dart';

/// A bounded dot strip whose active pill contracts while moving between dots.
class HomeCarouselIndicator extends StatelessWidget {
  static const _dotSpacing = 18.0;
  static const _edgeInset = 12.0;
  final int count;
  final PageController controller;

  const HomeCarouselIndicator({
    super.key,
    required this.count,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    if (count <= 1) return const SizedBox.shrink();
    final colors = AppColors.of(context);
    return LayoutBuilder(builder: (context, constraints) {
      final visible = math.min(
          count,
          (((constraints.maxWidth - _edgeInset * 2) / _dotSpacing).floor() + 1)
              .clamp(1, 7));
      final width = math.min(
          constraints.maxWidth, (visible - 1) * _dotSpacing + _edgeInset * 2);
      return Center(
        child: SizedBox(
          width: width,
          height: 10,
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, _) {
              final page =
                  (controller.hasClients && controller.position.haveDimensions
                          ? controller.page ?? controller.initialPage.toDouble()
                          : controller.initialPage.toDouble())
                      .clamp(0.0, count - 1.0);
              final start = (page - (visible - 1) / 2)
                  .clamp(0.0, (count - visible).toDouble());
              final first = math.max(0, start.floor() - 1);
              final last = math.min(count - 1, start.ceil() + visible);
              final phase = page - page.floor();
              final reduceMotion = MediaQuery.disableAnimationsOf(context);
              final contraction =
                  math.pow(math.sin(math.pi * phase), 2).toDouble();
              final markerWidth =
                  reduceMotion ? 18.0 : 18.0 - 12.0 * contraction;
              final center = _edgeInset + (page - start) * _dotSpacing;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  for (var index = first; index <= last; index++)
                    if (_edgeInset + (index - start) * _dotSpacing > 0 &&
                        _edgeInset + (index - start) * _dotSpacing < width)
                      _dot(_edgeInset + (index - start) * _dotSpacing, width,
                          colors.grass),
                  Positioned(
                    left: center - markerWidth / 2,
                    top: 2,
                    child: SizedBox(
                      key: const ValueKey('home-carousel-active-indicator'),
                      width: markerWidth,
                      height: 6,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: colors.grass,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      );
    });
  }

  Widget _dot(double center, double width, Color color) {
    // Edge dots shrink as whole circles rather than being cut by a viewport.
    final visibility =
        (math.min(center, width - center) / _edgeInset).clamp(0.0, 1.0);
    final diameter = 6 * visibility;
    return Positioned(
      left: center - diameter / 2,
      top: (10 - diameter) / 2,
      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.24 * visibility),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
