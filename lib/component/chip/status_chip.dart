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
    Color textColor = appColors.dirt;

    switch (status) {
      case ChipStatus.success:
        backgroundColor = appColors.successSurface;
        textColor = appColors.successForeground;
      case ChipStatus.warning:
        backgroundColor = appColors.warningSurface;
        textColor = appColors.warningForeground;
      case ChipStatus.error:
        backgroundColor = appColors.errorSurface;
        textColor = appColors.errorForeground;
      case ChipStatus.info:
        backgroundColor = appColors.infoSurface;
        textColor = appColors.infoForeground;
      case ChipStatus.normal:
        backgroundColor = appColors.offWhite;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(1000),
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
