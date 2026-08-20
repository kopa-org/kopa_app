import 'package:flutter/material.dart';

enum TeamLogoShape { circle, square, shield, rounded }

enum TeamLogoPattern { solid, verticalSplit, horizontalSplit, gradient }

class TeamLogoDesign {
  static const defaultColor = Color(0xFF1B8B4B);
  static const defaultDesign = TeamLogoDesign();

  final Color color;
  final TeamLogoShape shape;
  final TeamLogoPattern pattern;

  const TeamLogoDesign({
    this.color = defaultColor,
    this.shape = TeamLogoShape.circle,
    this.pattern = TeamLogoPattern.solid,
  });

  factory TeamLogoDesign.fromJson(Map<String, dynamic> json) {
    return TeamLogoDesign(
      color: colorFromHex(json['logo_color'] ?? json['logoColor']),
      shape: _enumFromName(
        TeamLogoShape.values,
        json['logo_shape'] ?? json['logoShape'],
        TeamLogoShape.circle,
      ),
      pattern: _enumFromName(
        TeamLogoPattern.values,
        json['logo_pattern'] ?? json['logoPattern'],
        TeamLogoPattern.solid,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'logo_color': colorToHex(color),
      'logo_shape': shape.name,
      'logo_pattern': pattern.name,
    };
  }

  static Color colorFromHex(dynamic value) {
    if (value is! String) return defaultColor;

    final normalized = value.trim().replaceFirst('#', '');
    if (normalized.length != 6 && normalized.length != 8) {
      return defaultColor;
    }

    final parsed = int.tryParse(normalized, radix: 16);
    if (parsed == null) return defaultColor;
    return Color(normalized.length == 6 ? 0xFF000000 | parsed : parsed);
  }

  static String colorToHex(Color color) {
    final rgb = color.toARGB32() & 0xFFFFFF;
    return '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }

  static T _enumFromName<T extends Enum>(
    List<T> values,
    dynamic value,
    T fallback,
  ) {
    final name = value?.toString();
    return values.firstWhere(
      (item) => item.name == name,
      orElse: () => fallback,
    );
  }
}
