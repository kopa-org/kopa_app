import 'package:flutter/material.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: const Color(0xFF5856D6),
      scaffoldBackgroundColor: AppColors.light.background,
      extensions: const <ThemeExtension<dynamic>>[
        AppColors.light,
        AppTextStyles.light,
      ],
    );
  }
}