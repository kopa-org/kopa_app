import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:kopa/theme/app_text_styles.dart';

class TeamAvatar extends StatelessWidget {
  static final Map<String, Future<ColorScheme?>> _colorSchemeCache = {};

  final String teamName;
  final int teamId;
  final String? colorSourceUrl;
  final double radius;

  const TeamAvatar({
    required this.teamName,
    required this.teamId,
    this.colorSourceUrl,
    this.radius = 24,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final seed = _stableSeed('$teamId:$teamName');
    final fallbackColors = _badgePalettes[seed % _badgePalettes.length];
    final normalizedUrl = colorSourceUrl?.trim();

    return Semantics(
      image: true,
      label: '$teamName holdmærke',
      child: FutureBuilder<ColorScheme?>(
        future: normalizedUrl == null || normalizedUrl.isEmpty
            ? null
            : _colorSchemeCache.putIfAbsent(
                normalizedUrl,
                () => _extractColorScheme(normalizedUrl),
              ),
        builder: (context, snapshot) {
          final colorScheme = snapshot.data;
          final colors = colorScheme == null
              ? fallbackColors
              : (colorScheme.primary, colorScheme.tertiary);

          return CustomPaint(
            size: Size.square(radius * 2),
            painter: _TeamBadgePainter(
              primary: colors.$1,
              secondary: colors.$2,
              pattern: seed % 4,
            ),
            child: SizedBox.square(
              dimension: radius * 2,
              child: Center(
                child: Text(
                  _initials(teamName),
                  style: appTextStyles.buttonTiny.copyWith(
                    color: Colors.white,
                    fontSize: radius * 0.72,
                    fontWeight: FontWeight.w700,
                    shadows: const [
                      Shadow(color: Color(0x66000000), blurRadius: 2),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  static Future<ColorScheme?> _extractColorScheme(String imageUrl) async {
    try {
      return await ColorScheme.fromImageProvider(
        provider: NetworkImage(imageUrl),
        brightness: Brightness.light,
        dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
      );
    } catch (_) {
      return null;
    }
  }
}

class _TeamBadgePainter extends CustomPainter {
  final Color primary;
  final Color secondary;
  final int pattern;

  const _TeamBadgePainter({
    required this.primary,
    required this.secondary,
    required this.pattern,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    final center = bounds.center;
    final radius = size.shortestSide / 2;

    canvas.save();
    canvas.clipPath(Path()..addOval(bounds));
    canvas.drawColor(primary, BlendMode.src);

    final secondaryPaint = Paint()..color = secondary;
    final stripePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.34)
      ..strokeWidth = math.max(2, size.width * 0.14);

    switch (pattern) {
      case 0:
        canvas.drawRect(
          Rect.fromLTWH(size.width / 2, 0, size.width / 2, size.height),
          secondaryPaint,
        );
        canvas.drawLine(
          Offset(size.width / 2, 0),
          Offset(size.width / 2, size.height),
          stripePaint,
        );
      case 1:
        canvas.drawPath(
          Path()
            ..moveTo(0, size.height)
            ..lineTo(size.width, 0)
            ..lineTo(size.width, size.height)
            ..close(),
          secondaryPaint,
        );
        canvas.drawLine(
          Offset(0, size.height),
          Offset(size.width, 0),
          stripePaint,
        );
      case 2:
        canvas.drawRect(
          Rect.fromLTWH(0, size.height / 2, size.width, size.height / 2),
          secondaryPaint,
        );
        canvas.drawLine(
          Offset(0, size.height / 2),
          Offset(size.width, size.height / 2),
          stripePaint,
        );
      case 3:
        canvas.drawCircle(center, radius * 0.62, secondaryPaint);
        canvas.drawCircle(
          center,
          radius * 0.69,
          Paint()
            ..color = Colors.white.withValues(alpha: 0.34)
            ..style = PaintingStyle.stroke
            ..strokeWidth = math.max(2, size.width * 0.1),
        );
    }

    canvas.restore();
    canvas.drawCircle(
      center,
      radius - 0.75,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant _TeamBadgePainter oldDelegate) =>
      oldDelegate.primary != primary ||
      oldDelegate.secondary != secondary ||
      oldDelegate.pattern != pattern;
}

const _badgePalettes = <(Color, Color)>[
  (Color(0xFF1975F2), Color(0xFF00943C)),
  (Color(0xFFED2415), Color(0xFF2D1000)),
  (Color(0xFFFF9F1A), Color(0xFF1975F2)),
  (Color(0xFF7B3FB5), Color(0xFF00943C)),
  (Color(0xFF00838F), Color(0xFFFF9F1A)),
  (Color(0xFF455A64), Color(0xFFED2415)),
  (Color(0xFF3949AB), Color(0xFF00A86B)),
  (Color(0xFFC2185B), Color(0xFF1975F2)),
];

int _stableSeed(String value) {
  var hash = 0x811C9DC5;
  for (final codeUnit in value.codeUnits) {
    hash ^= codeUnit;
    hash = (hash * 0x01000193) & 0x7FFFFFFF;
  }
  return hash;
}

String _initials(String name) {
  final words = name.trim().split(RegExp(r'\s+'));
  return words
      .where((word) => word.isNotEmpty)
      .take(2)
      .map((word) => word[0].toUpperCase())
      .join();
}
