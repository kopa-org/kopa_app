import 'package:flutter/material.dart';

class AppColors extends ThemeExtension<AppColors> {
  final Color productRowDivider;
  final Color searchBackground;
  final Color searchCursorColor;
  final Color searchIconColor;

  const AppColors({
    required this.productRowDivider,
    required this.searchBackground,
    required this.searchCursorColor,
    required this.searchIconColor,
  });

  @override
  AppColors copyWith({
    Color? productRowDivider,
    Color? searchBackground,
    Color? searchCursorColor,
    Color? searchIconColor,
  }) {
    return AppColors(
      productRowDivider: productRowDivider ?? this.productRowDivider,
      searchBackground: searchBackground ?? this.searchBackground,
      searchCursorColor: searchCursorColor ?? this.searchCursorColor,
      searchIconColor: searchIconColor ?? this.searchIconColor,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) {
      return this;
    }
    return AppColors(
      productRowDivider: Color.lerp(productRowDivider, other.productRowDivider, t)!,
      searchBackground: Color.lerp(searchBackground, other.searchBackground, t)!,
      searchCursorColor: Color.lerp(searchCursorColor, other.searchCursorColor, t)!,
      searchIconColor: Color.lerp(searchIconColor, other.searchIconColor, t)!,
    );
  }
}
