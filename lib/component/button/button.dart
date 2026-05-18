import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';

class Button extends StatelessWidget {
  final String buttonText;
  final VoidCallback onPressed;
  final bool outlined;
  final bool enabled;
  final IconData? icon;
  final double? width;

  const Button({
    super.key,
    required this.buttonText,
    required this.onPressed,
    this.outlined = false,
    this.enabled = true,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>() ?? AppColors.light;
    final appTextStyles = theme.extension<AppTextStyles>() ?? AppTextStyles.light;

    final Color bgColor = outlined
        ? appColors.surface
        : (enabled
            ? appColors.primary
            : appColors.divider);

    final Color borderColor = outlined
        ? (enabled ? appColors.primary : appColors.divider)
        : Colors.transparent;

    final Color textColor = outlined
        ? (enabled ? appColors.primary : appColors.textSecondary)
        : (enabled ? Colors.white : appColors.textSecondary);

    return Semantics(
      button: true,
      enabled: enabled,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: enabled ? onPressed : null,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 150),
          opacity: enabled ? 1.0 : 0.5,
          child: Container(
            width: width,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(50.0),
              border:
                  outlined ? Border.all(color: borderColor, width: 2.0) : null,
            ),
            padding:
                const EdgeInsets.symmetric(vertical: 15.0, horizontal: 30.0),
            child: Row(
              mainAxisSize: width == double.infinity ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    color: textColor,
                    size: 20,
                  ),
                  const SizedBox(width: 5),
                ],
                Text(
                  buttonText,
                  style: appTextStyles.button.copyWith(
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
