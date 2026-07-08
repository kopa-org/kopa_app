import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';

enum FullWidthButtonVariant { grass, sky }

class FullWidthButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback onPressed;
  final bool outlined;
  final IconData? icon;
  final FullWidthButtonVariant variant;

  const FullWidthButton({
    super.key,
    required this.buttonText,
    required this.onPressed,
    this.outlined = false,
    this.icon = Icons.arrow_forward,
    this.variant = FullWidthButtonVariant.grass,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final appTextStyles =
        theme.extension<AppTextStyles>() ?? AppTextStyles.light;
    final backgroundColor = switch (variant) {
      FullWidthButtonVariant.grass => appColors.lightGrass,
      FullWidthButtonVariant.sky => appColors.lightSky65,
    };

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14.0),
        decoration: BoxDecoration(
          color: outlined ? appColors.surface : backgroundColor,
          borderRadius: BorderRadius.circular(12.0),
          border: outlined
              ? Border.all(color: appColors.divider, width: 2.0)
              : null,
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              buttonText,
              style: appTextStyles.button.copyWith(
                color: appColors.black,
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: 8),
              Icon(
                icon,
                color: appColors.black,
                size: 20,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
