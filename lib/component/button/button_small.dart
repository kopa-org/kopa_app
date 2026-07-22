import 'package:flutter/cupertino.dart';

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
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Container(
        decoration: BoxDecoration(
          color:
              outlined ? CupertinoColors.white : CupertinoColors.systemIndigo,
          borderRadius: BorderRadius.circular(50.0),
        ),
        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null)
              Padding(
                padding: const EdgeInsets.only(right: 5.0),
                child: Icon(
                  icon,
                  color: outlined
                      ? CupertinoColors.systemIndigo
                      : CupertinoColors.white,
                  size: 22,
                ),
              ),
            Text(
              buttonText,
              style: TextStyle(
                color: outlined
                    ? CupertinoColors.systemIndigo
                    : CupertinoColors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
