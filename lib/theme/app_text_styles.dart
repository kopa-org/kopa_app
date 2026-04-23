import 'package:flutter/material.dart';

class AppTextStyles extends ThemeExtension<AppTextStyles> {
  final TextStyle pageTitle;
  final TextStyle sectionHeader;
  final TextStyle bodyBold;
  final TextStyle body;
  final TextStyle caption;
  final TextStyle button;

  const AppTextStyles({
    required this.pageTitle,
    required this.sectionHeader,
    required this.bodyBold,
    required this.body,
    required this.caption,
    required this.button,
  });

  static const AppTextStyles light = AppTextStyles(
    pageTitle: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: Color(0xFF000000),
    ),
    sectionHeader: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: Color(0xFF000000),
    ),
    bodyBold: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Color(0xFF000000),
    ),
    body: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: Color(0xFF000000),
    ),
    caption: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.normal,
      color: Color(0xFF8E8E93),
    ),
    button: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Color(0xffffffff),
    ),
  );

  @override
  AppTextStyles copyWith({
    TextStyle? pageTitle,
    TextStyle? sectionHeader,
    TextStyle? bodyBold,
    TextStyle? body,
    TextStyle? caption,
    TextStyle? button,
  }) {
    return AppTextStyles(
      pageTitle: pageTitle ?? this.pageTitle,
      sectionHeader: sectionHeader ?? this.sectionHeader,
      bodyBold: bodyBold ?? this.bodyBold,
      body: body ?? this.body,
      caption: caption ?? this.caption,
      button: button ?? this.button,
    );
  }

  @override
  AppTextStyles lerp(ThemeExtension<AppTextStyles>? other, double t) {
    if (other is! AppTextStyles) {
      return this;
    }
    return AppTextStyles(
      pageTitle: TextStyle.lerp(pageTitle, other.pageTitle, t)!,
      sectionHeader: TextStyle.lerp(sectionHeader, other.sectionHeader, t)!,
      bodyBold: TextStyle.lerp(bodyBold, other.bodyBold, t)!,
      body: TextStyle.lerp(body, other.body, t)!,
      caption: TextStyle.lerp(caption, other.caption, t)!,
      button: TextStyle.lerp(button, other.button, t)!,
    );
  }
}