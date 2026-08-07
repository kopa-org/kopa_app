import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles extends ThemeExtension<AppTextStyles> {
  final TextStyle pageTitle;
  final TextStyle sectionHeader;
  final TextStyle bodyBold;
  final TextStyle body;
  final TextStyle caption;
  final TextStyle button;

  // Figma text tokens
  final TextStyle h2;
  final TextStyle h3;
  final TextStyle h4;
  final TextStyle h5;
  final TextStyle subtitle1;
  final TextStyle subtitle2;
  final TextStyle body1;
  final TextStyle body3;
  final TextStyle body4;
  final TextStyle caption1;
  final TextStyle caption2;
  final TextStyle caption3;
  final TextStyle label;
  final TextStyle buttonGiant;
  final TextStyle buttonSmall;
  final TextStyle buttonTiny;

  const AppTextStyles({
    required this.pageTitle,
    required this.sectionHeader,
    required this.bodyBold,
    required this.body,
    required this.caption,
    required this.button,
    required this.h2,
    required this.h3,
    required this.h4,
    required this.h5,
    required this.subtitle1,
    required this.subtitle2,
    required this.body1,
    required this.body3,
    required this.body4,
    required this.caption1,
    required this.caption2,
    required this.caption3,
    required this.label,
    required this.buttonGiant,
    required this.buttonSmall,
    required this.buttonTiny,
  });

  static const Color _dirt = Color(0xFF2D1000);
  static const Color _grey5 = Color(0xFF6D7B77);
  static const Color _white = Color(0xFFFDFDFD);

  static TextStyle _rethink({
    required double fontSize,
    required FontWeight fontWeight,
    required double height,
    required Color color,
    double letterSpacing = 0,
  }) {
    return GoogleFonts.rethinkSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      letterSpacing: letterSpacing,
      color: color,
    );
  }

  static double _minusThreePercent(double fontSize) => -0.03 * fontSize;

  static AppTextStyles get light {
    // Fonts are bundled with the app, so rendering must not depend on a
    // runtime request to fonts.gstatic.com.
    GoogleFonts.config.allowRuntimeFetching = false;

    final h2 = _rethink(
      fontSize: 40,
      fontWeight: FontWeight.w600,
      height: 1.1,
      letterSpacing: _minusThreePercent(40),
      color: _dirt,
    );
    final h3 = _rethink(
      fontSize: 32,
      fontWeight: FontWeight.w600,
      height: 1.1,
      letterSpacing: _minusThreePercent(32),
      color: _dirt,
    );
    final h4 = _rethink(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      height: 1.1,
      letterSpacing: _minusThreePercent(28),
      color: _dirt,
    );
    final h5 = _rethink(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      height: 1.1,
      letterSpacing: _minusThreePercent(24),
      color: _dirt,
    );
    final subtitle1 = _rethink(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      height: 1.2,
      color: _dirt,
    );
    final subtitle2 = _rethink(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.2,
      color: _dirt,
    );
    final body1 = _rethink(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.2,
      color: _dirt,
    );
    final body3 = _rethink(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.2,
      color: _dirt,
    );
    final body4 = _rethink(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 1.2,
      color: _dirt,
    );
    final caption1 = _rethink(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.1,
      color: _grey5,
    );
    final caption2 = _rethink(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      height: 1.1,
      color: _grey5,
    );
    final caption3 = _rethink(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      height: 1.1,
      color: _grey5,
    );
    final label = _rethink(
      fontSize: 8,
      fontWeight: FontWeight.w500,
      height: 1.1,
      color: _grey5,
    );
    final buttonGiant = _rethink(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      height: 1.1,
      color: _dirt,
    );
    final buttonSmall = _rethink(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      height: 1.1,
      color: _dirt,
    );
    final buttonTiny = _rethink(
      fontSize: 10,
      fontWeight: FontWeight.w600,
      height: 1.1,
      color: _dirt,
    );

    return AppTextStyles(
      pageTitle: h4,
      sectionHeader: h5,
      bodyBold: subtitle2,
      body: body1,
      caption: caption1,
      button: buttonGiant.copyWith(color: _white),
      h2: h2,
      h3: h3,
      h4: h4,
      h5: h5,
      subtitle1: subtitle1,
      subtitle2: subtitle2,
      body1: body1,
      body3: body3,
      body4: body4,
      caption1: caption1,
      caption2: caption2,
      caption3: caption3,
      label: label,
      buttonGiant: buttonGiant,
      buttonSmall: buttonSmall,
      buttonTiny: buttonTiny,
    );
  }

  @override
  AppTextStyles copyWith({
    TextStyle? pageTitle,
    TextStyle? sectionHeader,
    TextStyle? bodyBold,
    TextStyle? body,
    TextStyle? caption,
    TextStyle? button,
    TextStyle? h2,
    TextStyle? h3,
    TextStyle? h4,
    TextStyle? h5,
    TextStyle? subtitle1,
    TextStyle? subtitle2,
    TextStyle? body1,
    TextStyle? body3,
    TextStyle? body4,
    TextStyle? caption1,
    TextStyle? caption2,
    TextStyle? caption3,
    TextStyle? label,
    TextStyle? buttonGiant,
    TextStyle? buttonSmall,
    TextStyle? buttonTiny,
  }) {
    return AppTextStyles(
      pageTitle: pageTitle ?? this.pageTitle,
      sectionHeader: sectionHeader ?? this.sectionHeader,
      bodyBold: bodyBold ?? this.bodyBold,
      body: body ?? this.body,
      caption: caption ?? this.caption,
      button: button ?? this.button,
      h2: h2 ?? this.h2,
      h3: h3 ?? this.h3,
      h4: h4 ?? this.h4,
      h5: h5 ?? this.h5,
      subtitle1: subtitle1 ?? this.subtitle1,
      subtitle2: subtitle2 ?? this.subtitle2,
      body1: body1 ?? this.body1,
      body3: body3 ?? this.body3,
      body4: body4 ?? this.body4,
      caption1: caption1 ?? this.caption1,
      caption2: caption2 ?? this.caption2,
      caption3: caption3 ?? this.caption3,
      label: label ?? this.label,
      buttonGiant: buttonGiant ?? this.buttonGiant,
      buttonSmall: buttonSmall ?? this.buttonSmall,
      buttonTiny: buttonTiny ?? this.buttonTiny,
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
      h2: TextStyle.lerp(h2, other.h2, t)!,
      h3: TextStyle.lerp(h3, other.h3, t)!,
      h4: TextStyle.lerp(h4, other.h4, t)!,
      h5: TextStyle.lerp(h5, other.h5, t)!,
      subtitle1: TextStyle.lerp(subtitle1, other.subtitle1, t)!,
      subtitle2: TextStyle.lerp(subtitle2, other.subtitle2, t)!,
      body1: TextStyle.lerp(body1, other.body1, t)!,
      body3: TextStyle.lerp(body3, other.body3, t)!,
      body4: TextStyle.lerp(body4, other.body4, t)!,
      caption1: TextStyle.lerp(caption1, other.caption1, t)!,
      caption2: TextStyle.lerp(caption2, other.caption2, t)!,
      caption3: TextStyle.lerp(caption3, other.caption3, t)!,
      label: TextStyle.lerp(label, other.label, t)!,
      buttonGiant: TextStyle.lerp(buttonGiant, other.buttonGiant, t)!,
      buttonSmall: TextStyle.lerp(buttonSmall, other.buttonSmall, t)!,
      buttonTiny: TextStyle.lerp(buttonTiny, other.buttonTiny, t)!,
    );
  }
}
