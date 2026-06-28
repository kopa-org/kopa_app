import 'package:flutter/material.dart';

class AppColors extends ThemeExtension<AppColors> {
  final Color background;
  final Color surface;
  final Color primary;
  final Color divider;
  final Color textPrimary;
  final Color textSecondary;

  // Figma / brand colors
  final Color lightGrass;
  final Color offWhite;
  final Color white;
  final Color black;
  final Color grass;
  final Color dirt;
  final Color sky;
  final Color lightSky;
  final Color sunset;
  final Color sun;

  // Figma support colors and tints
  final Color grey2;
  final Color grey3;
  final Color grey4;
  final Color grey5;
  final Color grey7;
  final Color lightSky55;
  final Color lightSky65;
  final Color lightSky95;
  final Color lightGrass55;
  final Color lightGrass65;
  final Color lightGrass75;
  final Color lightGrass95;

  // Semantic colors
  final Color success;
  final Color warning;
  final Color error;

  const AppColors({
    required this.background,
    required this.surface,
    required this.primary,
    required this.divider,
    required this.textPrimary,
    required this.textSecondary,
    required this.lightGrass,
    required this.offWhite,
    required this.white,
    required this.black,
    required this.grass,
    required this.dirt,
    required this.sky,
    required this.lightSky,
    required this.sunset,
    required this.sun,
    required this.grey2,
    required this.grey3,
    required this.grey4,
    required this.grey5,
    required this.grey7,
    required this.lightSky55,
    required this.lightSky65,
    required this.lightSky95,
    required this.lightGrass55,
    required this.lightGrass65,
    required this.lightGrass75,
    required this.lightGrass95,
    required this.success,
    required this.warning,
    required this.error,
  });

  static const AppColors light = AppColors(
    background: Color(0xFFFDFDFD),//Color(0xFFE8F2ED), // Off White
    surface: Color(0xFFFDFDFD), // Figma White
    primary: Color(0xFF00943C), // Græs / Grass
    divider: Color(0xFFB7B7B7), // Grey 3
    textPrimary: Color(0xFF2D1000), // Jord
    textSecondary: Color(0xFF6D7B77), // Grey 5
    lightGrass: Color(0xFF9FFDCC),
    offWhite: Color(0xFFE8F2ED),
    white: Color(0xFFFDFDFD),
    // Kept for legacy overlays not present as a Figma token.
    black: Color(0xFF101010),
    grass: Color(0xFF00943C),
    dirt: Color(0xFF2D1000),
    sky: Color(0xFF1975F2),
    lightSky: Color(0xFFA0EAFF),
    sunset: Color(0xFFFF9F1A),
    sun: Color(0xFFFFFF00),
    grey2: Color(0xFFECF8F0),
    grey3: Color(0xFFB7B7B7),
    grey4: Color(0xFF94A099),
    grey5: Color(0xFF6D7B77),
    grey7: Color(0xFF454B45),
    lightSky55: Color(0xFFEEFBFF),
    lightSky65: Color(0xFFD1F5FF),
    lightSky95: Color(0xFFA9ECFF),
    lightGrass55: Color(0xFFE7FFF2),
    lightGrass65: Color(0xFFE7FFF2),
    lightGrass75: Color(0xFFD9FEEB),
    lightGrass95: Color(0xFFBCFEDB),
    success: Color(0xFF00BF65),
    warning: Color(0xFFFF9F1A), // Figma has no warning token; use Solnedgang
    error: Color(0xFFED2415),
  );

  @override
  AppColors copyWith({
    Color? background,
    Color? surface,
    Color? primary,
    Color? divider,
    Color? textPrimary,
    Color? textSecondary,
    Color? lightGrass,
    Color? offWhite,
    Color? white,
    Color? black,
    Color? grass,
    Color? dirt,
    Color? sky,
    Color? lightSky,
    Color? sunset,
    Color? sun,
    Color? grey2,
    Color? grey3,
    Color? grey4,
    Color? grey5,
    Color? grey7,
    Color? lightSky55,
    Color? lightSky65,
    Color? lightSky95,
    Color? lightGrass55,
    Color? lightGrass65,
    Color? lightGrass75,
    Color? lightGrass95,
    Color? success,
    Color? warning,
    Color? error,
  }) {
    return AppColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      primary: primary ?? this.primary,
      divider: divider ?? this.divider,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      lightGrass: lightGrass ?? this.lightGrass,
      offWhite: offWhite ?? this.offWhite,
      white: white ?? this.white,
      black: black ?? this.black,
      grass: grass ?? this.grass,
      dirt: dirt ?? this.dirt,
      sky: sky ?? this.sky,
      lightSky: lightSky ?? this.lightSky,
      sunset: sunset ?? this.sunset,
      sun: sun ?? this.sun,
      grey2: grey2 ?? this.grey2,
      grey3: grey3 ?? this.grey3,
      grey4: grey4 ?? this.grey4,
      grey5: grey5 ?? this.grey5,
      grey7: grey7 ?? this.grey7,
      lightSky55: lightSky55 ?? this.lightSky55,
      lightSky65: lightSky65 ?? this.lightSky65,
      lightSky95: lightSky95 ?? this.lightSky95,
      lightGrass55: lightGrass55 ?? this.lightGrass55,
      lightGrass65: lightGrass65 ?? this.lightGrass65,
      lightGrass75: lightGrass75 ?? this.lightGrass75,
      lightGrass95: lightGrass95 ?? this.lightGrass95,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) {
      return this;
    }
    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      lightGrass: Color.lerp(lightGrass, other.lightGrass, t)!,
      offWhite: Color.lerp(offWhite, other.offWhite, t)!,
      white: Color.lerp(white, other.white, t)!,
      black: Color.lerp(black, other.black, t)!,
      grass: Color.lerp(grass, other.grass, t)!,
      dirt: Color.lerp(dirt, other.dirt, t)!,
      sky: Color.lerp(sky, other.sky, t)!,
      lightSky: Color.lerp(lightSky, other.lightSky, t)!,
      sunset: Color.lerp(sunset, other.sunset, t)!,
      sun: Color.lerp(sun, other.sun, t)!,
      grey2: Color.lerp(grey2, other.grey2, t)!,
      grey3: Color.lerp(grey3, other.grey3, t)!,
      grey4: Color.lerp(grey4, other.grey4, t)!,
      grey5: Color.lerp(grey5, other.grey5, t)!,
      grey7: Color.lerp(grey7, other.grey7, t)!,
      lightSky55: Color.lerp(lightSky55, other.lightSky55, t)!,
      lightSky65: Color.lerp(lightSky65, other.lightSky65, t)!,
      lightSky95: Color.lerp(lightSky95, other.lightSky95, t)!,
      lightGrass55: Color.lerp(lightGrass55, other.lightGrass55, t)!,
      lightGrass65: Color.lerp(lightGrass65, other.lightGrass65, t)!,
      lightGrass75: Color.lerp(lightGrass75, other.lightGrass75, t)!,
      lightGrass95: Color.lerp(lightGrass95, other.lightGrass95, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
    );
  }
}
