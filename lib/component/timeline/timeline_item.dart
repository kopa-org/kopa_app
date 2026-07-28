import 'package:flutter/material.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/theme/spacing.dart';

class TimelineItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String time;
  final IconData icon;
  final bool isLast;
  final Color? iconColor;

  const TimelineItem({
    super.key,
    required this.title,
    this.subtitle,
    required this.time,
    required this.icon,
    this.isLast = false,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 40,
            child: Text(
              time,
              textAlign: TextAlign.right,
              style: appTextStyles.body3.copyWith(
                color: appColors.dirt,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: Spacing.md),
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: appColors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: appColors.grey3),
                    boxShadow: [
                      BoxShadow(
                        color: appColors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    size: 14,
                    color: iconColor ?? appColors.primary,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: appColors.grey3.withValues(alpha: 0.5),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: appTextStyles.body3.copyWith(
                      color: appColors.dirt,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: appTextStyles.caption1.copyWith(
                        color: appColors.dirt,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
