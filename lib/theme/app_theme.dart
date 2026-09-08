import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';

class AppTheme {
  static final _buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  );

  static ThemeData get lightTheme {
    const colors = AppColors.light;
    final styles = AppTextStyles.light;
    final textTheme = TextTheme(
      displayLarge: styles.h2,
      displayMedium: styles.h3,
      displaySmall: styles.h4,
      headlineLarge: styles.h3,
      headlineMedium: styles.pageTitle,
      headlineSmall: styles.h5,
      titleLarge: styles.sectionHeader,
      titleMedium: styles.subtitle2,
      titleSmall: styles.body4,
      bodyLarge: styles.body,
      bodyMedium: styles.body3,
      bodySmall: styles.caption,
      labelLarge: styles.button,
      labelMedium: styles.caption2,
      labelSmall: styles.caption2,
    );
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    );
    final primaryButton = FilledButton.styleFrom(
      backgroundColor: colors.lightGrass,
      foregroundColor: colors.dirt,
      disabledBackgroundColor: colors.offWhite,
      disabledForegroundColor: colors.textSecondary,
      minimumSize: const Size(48, 48),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      textStyle: styles.button,
      shape: _buttonShape,
      elevation: 0,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: colors.grass,
        brightness: Brightness.light,
        primary: colors.grass,
        onPrimary: colors.white,
        primaryContainer: colors.lightGrass,
        onPrimaryContainer: colors.dirt,
        secondary: colors.successForeground,
        onSecondary: colors.white,
        secondaryContainer: colors.lightGrass55,
        onSecondaryContainer: colors.dirt,
        surface: colors.surface,
        onSurface: colors.dirt,
        onSurfaceVariant: colors.textSecondary,
        error: colors.errorForeground,
        onError: colors.white,
        errorContainer: colors.errorSurface,
        onErrorContainer: colors.errorForeground,
        outline: colors.grey4,
        outlineVariant: colors.offWhite,
      ),
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      scaffoldBackgroundColor: colors.background,
      unselectedWidgetColor: colors.textSecondary,
      iconTheme: IconThemeData(color: colors.dirt, size: 22),
      cupertinoOverrideTheme: CupertinoThemeData(
        primaryColor: colors.successForeground,
        scaffoldBackgroundColor: colors.background,
        barBackgroundColor: colors.background,
        textTheme: CupertinoTextThemeData(
          textStyle: styles.body,
          actionTextStyle:
              styles.button.copyWith(color: colors.successForeground),
          navTitleTextStyle: styles.subtitle2,
          navLargeTitleTextStyle: styles.pageTitle,
          tabLabelTextStyle: styles.caption2,
        ),
      ),
      extensions: <ThemeExtension<dynamic>>[
        colors,
        styles,
      ],
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: primaryButton,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: primaryButton,
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: primaryButton.copyWith(
          backgroundColor: WidgetStatePropertyAll(colors.surface),
          side: const WidgetStatePropertyAll(BorderSide.none),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.successForeground,
          minimumSize: const Size(48, 48),
          textStyle: styles.bodyBold,
          shape: _buttonShape,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        foregroundColor: colors.dirt,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: styles.sectionHeader,
      ),
      cardTheme: CardThemeData(
        color: colors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surface,
        contentPadding: const EdgeInsets.all(16),
        border: inputBorder,
        enabledBorder: inputBorder,
        disabledBorder: inputBorder,
        focusedBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: colors.grass, width: 2),
        ),
        errorBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: colors.errorForeground),
        ),
        focusedErrorBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: colors.errorForeground, width: 2),
        ),
        labelStyle: styles.body3,
        hintStyle: styles.body.copyWith(color: colors.textSecondary),
        errorStyle: styles.caption.copyWith(color: colors.errorForeground),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: styles.sectionHeader,
        contentTextStyle: styles.body,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.lightGrass,
        foregroundColor: colors.dirt,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dividerTheme: DividerThemeData(color: colors.offWhite, thickness: 1),
      listTileTheme: ListTileThemeData(
        textColor: colors.dirt,
        iconColor: colors.dirt,
        titleTextStyle: styles.bodyBold,
        subtitleTextStyle: styles.body3.copyWith(color: colors.textSecondary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }
}
