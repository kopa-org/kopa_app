import 'package:flutter/material.dart';

class AppColors extends ThemeExtension<AppColors> {
  final Color background;
  final Color surface;
  final Color primary;
  final Color divider;
  final Color textPrimary;
  final Color textSecondary;
  
  // Design System Brand Colors
  final Color lightGrass;
  final Color offWhite;
  final Color black;
  final Color grass;
  final Color dirt;
  final Color sky;
  final Color lightSky;
  final Color sunset;
  final Color sun;
  
  // Semantic Colors
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
    required this.black,
    required this.grass,
    required this.dirt,
    required this.sky,
    required this.lightSky,
    required this.sunset,
    required this.sun,
    required this.success,
    required this.warning,
    required this.error,
  });

  static const AppColors light = AppColors(
    background: Color(0xFFE8F2ED), // Off White
    surface: Color(0xFFFFFFFF),
    primary: Color(0xFF00943C),    // Grass
    divider: Color(0xFFE5E5EA),
    textPrimary: Color(0xFF101010), // Black
    textSecondary: Color(0xFF2D1000), // Dirt/Jord as secondary text
    lightGrass: Color(0xFF9FFDCC),
    offWhite: Color(0xFFE8F2ED),
    black: Color(0xFF101010),
    grass: Color(0xFF00943C),
    dirt: Color(0xFF2D1000),
    sky: Color(0xFF1975F2),
    lightSky: Color(0xFFA0EAFF),
    sunset: Color(0xFFFF9F1A),
    sun: Color(0xFFFFFF00),
    success: Color(0xFF00BF65),
    warning: Color(0xFFFFBE2B),
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
    Color? black,
    Color? grass,
    Color? dirt,
    Color? sky,
    Color? lightSky,
    Color? sunset,
    Color? sun,
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
      black: black ?? this.black,
      grass: grass ?? this.grass,
      dirt: dirt ?? this.dirt,
      sky: sky ?? this.sky,
      lightSky: lightSky ?? this.lightSky,
      sunset: sunset ?? this.sunset,
      sun: sun ?? this.sun,
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
      black: Color.lerp(black, other.black, t)!,
      grass: Color.lerp(grass, other.grass, t)!,
      dirt: Color.lerp(dirt, other.dirt, t)!,
      sky: Color.lerp(sky, other.sky, t)!,
      lightSky: Color.lerp(lightSky, other.lightSky, t)!,
      sunset: Color.lerp(sunset, other.sunset, t)!,
      sun: Color.lerp(sun, other.sun, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
    );
  }
}