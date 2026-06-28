import 'package:flutter/material.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';

class AppTheme {
  static ThemeData get lightTheme {
    const colors = AppColors.light;

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: colors.grass,
        brightness: Brightness.light,
        primary: colors.grass,
        secondary: colors.sky,
        surface: colors.surface,
        error: colors.error,
      ),
      scaffoldBackgroundColor: colors.background,
      extensions: <ThemeExtension<dynamic>>[
        colors,
        AppTextStyles.light,
      ],
    );
  }
}
