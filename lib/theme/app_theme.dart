import 'package:flutter/material.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: const Color(0xFF00943C), // Grass
      scaffoldBackgroundColor: AppColors.light.background,
      extensions: <ThemeExtension<dynamic>>[
        AppColors.light,
        AppTextStyles.light,
      ],
    );
  }
}