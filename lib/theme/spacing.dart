import 'package:flutter/material.dart';

class Spacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 16,
  );

  static const EdgeInsets cardPadding = EdgeInsets.all(16);
  static const EdgeInsets cardMargin = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 8,
  );

  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 12,
  );

  static const double borderRadius = 12;
  static const double borderRadiusExtraSmall = 4;
  static const double borderRadiusSmall = 8;
  static const double borderRadiusMedium = 12;
  static const double borderRadiusLarge = 16;
  static const double borderRadiusLargeIncreased = 20;
  static const double borderRadiusExtraLarge = 28;
  static const double borderRadiusFull = 1000;
}
