import 'package:flutter/material.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';

class FormCard extends StatelessWidget {
  final List<int> lastFiveMatchesForm;

  const FormCard({
    super.key,
    required this.lastFiveMatchesForm,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    return Container(
      decoration: BoxDecoration(
        color: appColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: appColors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Form (Seneste 5)',
            style: appTextStyles.bodyBold.copyWith(
              color: appColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              for (var index = 0; index < lastFiveMatchesForm.length; index++)
                Padding(
                  padding: EdgeInsets.only(
                    right: index == lastFiveMatchesForm.length - 1 ? 0 : 12,
                  ),
                  child: _FormResult(
                    result: lastFiveMatchesForm[index],
                    colors: appColors,
                    textStyles: appTextStyles,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FormResult extends StatelessWidget {
  final int result;
  final AppColors colors;
  final AppTextStyles textStyles;

  const _FormResult({
    required this.result,
    required this.colors,
    required this.textStyles,
  });

  @override
  Widget build(BuildContext context) {
    final (bgColor, label) = switch (result) {
      1 => (colors.success, 'V'),
      0 => (colors.warning, 'U'),
      _ => (colors.error, 'T'),
    };

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: bgColor.withValues(alpha: 0.4),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: textStyles.bodyBold.copyWith(
          color: Colors.white,
        ),
      ),
    );
  }
}
