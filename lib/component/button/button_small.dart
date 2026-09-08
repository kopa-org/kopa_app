import 'package:flutter/material.dart';
import 'package:kopa/component/button/button.dart';

class ButtonSmall extends StatelessWidget {
  final String buttonText;
  final VoidCallback onPressed;
  final bool outlined;
  final IconData? icon;

  const ButtonSmall({
    super.key,
    required this.buttonText,
    required this.onPressed,
    this.outlined = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) => Button(
        buttonText: buttonText,
        onPressed: onPressed,
        outlined: outlined,
        icon: icon,
      );
}
