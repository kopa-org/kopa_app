import 'package:flutter/material.dart';
import 'package:kopa/component/card/kopa_card.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/theme/spacing.dart';

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? color;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final appTextStyles = theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    return KopaCard(
      padding: const EdgeInsets.all(Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  label,
                  style: appTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (icon != null)
                Icon(
                  icon,
                  size: 16,
                  color: color ?? appColors.primary,
                ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            value,
            style: appTextStyles.pageTitle.copyWith(
              color: color ?? appColors.primary,
              fontSize: 24,
            ),
          ),
        ],
      ),
    );
  }
}
