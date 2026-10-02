import 'package:flutter/material.dart';
import 'package:kopa/theme/app_colors.dart';

class KopaCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final double borderRadius;
  final Color? color;
  final bool clip;
  final BorderSide borderSide;
  final List<BoxShadow> boxShadow;

  const KopaCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.borderRadius = 16,
    this.color,
    this.clip = false,
    this.borderSide = BorderSide.none,
    this.boxShadow = const [],
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final radius = BorderRadius.circular(borderRadius);
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: DecoratedBox(
        decoration: BoxDecoration(borderRadius: radius, boxShadow: boxShadow),
        child: Material(
          color: color ?? colors.surface,
          shape: RoundedRectangleBorder(borderRadius: radius, side: borderSide),
          clipBehavior: clip || onTap != null ? Clip.antiAlias : Clip.none,
          child: InkWell(
            onTap: onTap,
            borderRadius: radius,
            child: Padding(
              padding: padding ?? const EdgeInsets.all(16),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
