import 'package:flutter/material.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';

enum ChipStatus { success, warning, error, info, normal }

class StatusChip extends StatelessWidget {
  final String label;
  final ChipStatus status;

  const StatusChip({
    super.key,
    required this.label,
    this.status = ChipStatus.normal,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    Color backgroundColor;
    Color textColor = appColors.black;

    switch (status) {
      case ChipStatus.success:
        backgroundColor = appColors.success;
        textColor = Colors.white;
      case ChipStatus.warning:
        backgroundColor = appColors.warning;
      case ChipStatus.error:
        backgroundColor = appColors.error;
        textColor = Colors.white;
      case ChipStatus.info:
        backgroundColor = appColors.lightSky;
      case ChipStatus.normal:
        backgroundColor = appColors.divider;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: appTextStyles.caption.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
