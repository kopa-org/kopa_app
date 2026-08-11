import 'package:flutter/material.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/theme/spacing.dart';

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? value;
  final Widget? trailing;
  final Color? valueColor;
  final bool underlineValue;

  const InfoRow({
    super.key,
    required this.icon,
    required this.title,
    this.value,
    this.trailing,
    this.valueColor,
    this.underlineValue = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: appColors.primary,
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 112,
            child: Text(
              title,
              style: appTextStyles.body3.copyWith(
                color: const Color(0xFF524438),
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: Spacing.sm),
          if (value != null)
            Expanded(
              child: Text(
                value!,
                style: appTextStyles.body3.copyWith(
                  color: valueColor ?? appColors.dirt,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  decoration: underlineValue
                      ? TextDecoration.underline
                      : TextDecoration.none,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
              ),
            )
          else if (trailing != null)
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: trailing!,
              ),
            ),
        ],
      ),
    );
  }
}
