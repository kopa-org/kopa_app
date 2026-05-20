import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

  static AppTextStyles get light => AppTextStyles(
        pageTitle: GoogleFonts.rethinkSans(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF101010),
        ),
        sectionHeader: GoogleFonts.rethinkSans(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF101010),
        ),
        bodyBold: GoogleFonts.rethinkSans(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF101010),
        ),
        body: GoogleFonts.rethinkSans(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: const Color(0xFF101010),
        ),
        caption: GoogleFonts.rethinkSans(
          fontSize: 13,
          fontWeight: FontWeight.normal,
          color: const Color(0xFF2D1000),
        ),
        button: GoogleFonts.rethinkSans(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: const Color(0xFFFFFFFF),
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
