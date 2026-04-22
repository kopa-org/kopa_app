import 'package:flutter/material.dart';
import 'package:kopa/theme/app_colors.dart';
import 'package:kopa/theme/app_text_styles.dart';

class AppTheme {
  static const Color scaffoldBackground = Color(0xfff0f0f0);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: Colors.indigo,
      brightness: Brightness.light,
      scaffoldBackgroundColor: scaffoldBackground,
      extensions: const <ThemeExtension<dynamic>>[
        AppColors(
          productRowDivider: Color(0xFFD9D9D9),
          searchBackground: Color(0xffe0e0e0),
          searchCursorColor: Color.fromRGBO(0, 122, 255, 1),
          searchIconColor: Color.fromRGBO(128, 128, 128, 1),
        ),
        AppTextStyles(
          productRowItemName: TextStyle(
            color: Color.fromRGBO(0, 0, 0, 0.8),
            fontSize: 18,
            fontStyle: FontStyle.normal,
            fontWeight: FontWeight.normal,
          ),
          productRowTotal: TextStyle(
            color: Color.fromRGBO(0, 0, 0, 0.8),
            fontSize: 18,
            fontStyle: FontStyle.normal,
            fontWeight: FontWeight.bold,
          ),
          productRowItemPrice: TextStyle(
            color: Color(0xFF8E8E93),
            fontSize: 13,
            fontWeight: FontWeight.w300,
          ),
          searchText: TextStyle(
            color: Color.fromRGBO(0, 0, 0, 1),
            fontSize: 14,
            fontStyle: FontStyle.normal,
            fontWeight: FontWeight.normal,
          ),
          deliveryTimeLabel: TextStyle(
            color: Color(0xFFC2C2C2),
            fontWeight: FontWeight.w300,
          ),
          deliveryTime: TextStyle(
            color: Color(0xFF8E8E93), // Equivalent to CupertinoColors.inactiveGray
          ),
        ),
      ],
    );
  }
}
