import 'package:flutter/material.dart';
import 'package:kopa/component/button/button.dart';

enum FullWidthButtonVariant { grass, sky }

class FullWidthButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback onPressed;
  final bool outlined;
  final bool enabled;
  final bool loading;
  final IconData? icon;
  final FullWidthButtonVariant variant;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const FullWidthButton({
    super.key,
    required this.buttonText,
    required this.onPressed,
    this.outlined = false,
    this.enabled = true,
    this.loading = false,
    this.icon = Icons.arrow_forward,
    this.variant = FullWidthButtonVariant.grass,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Button(
      buttonText: buttonText,
      onPressed: onPressed,
      outlined: outlined,
      enabled: enabled,
      loading: loading,
      icon: icon,
      width: double.infinity,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      variant: variant == FullWidthButtonVariant.sky
          ? ButtonVariant.secondary
          : ButtonVariant.primary,
    );
  }
}
