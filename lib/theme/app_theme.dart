import 'package:flutter/material.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';

class AppTheme {
  static final _buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(8),
  );

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
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(shape: _buttonShape),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(shape: _buttonShape),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(shape: _buttonShape),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(shape: _buttonShape),
      ),
    );
  }
}
