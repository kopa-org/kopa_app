import 'package:flutter/material.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/theme/spacing.dart';

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? value;
  final Widget? trailing;

  const InfoRow({
    super.key,
    required this.icon,
    required this.title,
    this.value,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final appTextStyles = theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
      child: Row(
        children: [
          Icon(
            icon,
            size: 24,
            color: appColors.primary,
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Text(
              title,
              style: appTextStyles.body,
            ),
          ),
          if (value != null)
            Text(
              value!,
              style: appTextStyles.bodyBold,
            )
          else if (trailing != null)
            trailing!,
        ],
      ),
    );
  }
}
