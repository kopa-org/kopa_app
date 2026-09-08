import 'package:flutter/material.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';

enum ButtonVariant { primary, secondary, tertiary, destructive }

class Button extends StatelessWidget {
  final String buttonText;
  final VoidCallback onPressed;
  final bool outlined;
  final bool enabled;
  final bool loading;
  final IconData? icon;
  final double? width;
  final ButtonVariant variant;

  const Button({
    super.key,
    required this.buttonText,
    required this.onPressed,
    this.outlined = false,
    this.enabled = true,
    this.loading = false,
    this.icon,
    this.width,
    this.variant = ButtonVariant.primary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>() ?? AppColors.light;
    final styles = theme.extension<AppTextStyles>() ?? AppTextStyles.light;
    final role = outlined ? ButtonVariant.secondary : variant;
    final foreground = role == ButtonVariant.destructive
        ? colors.errorForeground
        : colors.dirt;
    final background = switch (role) {
      ButtonVariant.primary => colors.lightGrass,
      ButtonVariant.secondary => colors.surface,
      ButtonVariant.tertiary => Colors.transparent,
      ButtonVariant.destructive => colors.errorSurface,
    };

    return SizedBox(
      width: width,
      child: FilledButton(
        onPressed: enabled && !loading ? onPressed : null,
        style: FilledButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          disabledBackgroundColor: colors.offWhite,
          disabledForegroundColor: colors.textSecondary,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: styles.button,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Row(
          mainAxisSize:
              width == double.infinity ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (loading) ...[
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: foreground),
              ),
              const SizedBox(width: 8),
            ] else if (icon != null) ...[
              Icon(icon, size: 20),
              const SizedBox(width: 8),
            ],
            Flexible(child: Text(buttonText, textAlign: TextAlign.center)),
          ],
        ),
      ),
    );
  }
}
