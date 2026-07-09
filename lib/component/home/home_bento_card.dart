import 'package:flutter/material.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/theme/spacing.dart';

class HomeBentoCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final bool clip;

  const HomeBentoCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(Spacing.md),
    this.color,
    this.clip = false,
  });

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return Container(
      clipBehavior: clip ? Clip.antiAlias : Clip.none,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? appColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: appColors.grass),
        boxShadow: [
          BoxShadow(
            color: appColors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class HomeBentoSectionTitle extends StatelessWidget {
  final String title;

  const HomeBentoSectionTitle({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;

    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        textAlign: TextAlign.left,
        style: appTextStyles.h5.copyWith(
          color: appColors.dirt,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
