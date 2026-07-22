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
  final String? actionLabel;
  final VoidCallback? onAction;

  const HomeBentoSectionTitle({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final appColors =
        Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final titleWidget = Text(
      title,
      textAlign: TextAlign.left,
      style: appTextStyles.h5.copyWith(
        color: appColors.dirt,
        fontWeight: FontWeight.w900,
      ),
    );

    final onAction = this.onAction;
    if (onAction == null) {
      return Align(
        alignment: Alignment.centerLeft,
        child: titleWidget,
      );
    }

    return Row(
      children: [
        Expanded(child: titleWidget),
        TextButton.icon(
          onPressed: onAction,
          style: TextButton.styleFrom(
            foregroundColor: appColors.dirt,
            minimumSize: const Size(0, 34),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          iconAlignment: IconAlignment.end,
          icon: const Icon(Icons.arrow_forward, size: 16),
          label: Text(
            actionLabel ?? 'Gå til',
            style: appTextStyles.buttonTiny.copyWith(
              color: appColors.dirt,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}
