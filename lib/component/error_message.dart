import 'package:flutter/cupertino.dart';
import 'package:kopa/theme/app_colors.dart';

class ErrorMessage extends StatelessWidget {
  final String message;

  const ErrorMessage({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(top: 40.0), // Tilføjer plads til siderne
        child: Text(
          'Der skete en fejl. Prøv venligst igen senere.',
          style: TextStyle(
            fontSize: 16.0,
            color: AppColors.of(context).error,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
