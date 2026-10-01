import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:kopa/model/team_logo_design.dart';
import 'package:kopa/theme/app_text_styles.dart';
import 'package:kopa/theme/app_colors.dart';

class TeamAvatar extends StatelessWidget {
  static final Map<String, Future<ColorScheme?>> _colorSchemeCache = {};

  final String teamName;
  final int teamId;
  final String? colorSourceUrl;
  final TeamLogoDesign? logoDesign;
  final double radius;

  const TeamAvatar({
    required this.teamName,
    required this.teamId,
    this.colorSourceUrl,
    this.logoDesign,
    this.radius = 24,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final appTextStyles =
        Theme.of(context).extension<AppTextStyles>() ?? AppTextStyles.light;
    final seed = _stableSeed('$teamId:$teamName');
    final palettes = AppColors.of(context).teamBadgePalettes;
    final fallbackColors = palettes[seed % palettes.length];
    final normalizedUrl = colorSourceUrl?.trim();

    return Semantics(
      image: true,
      label: '$teamName holdmærke',
      child: FutureBuilder<ColorScheme?>(
        future:
            logoDesign != null || normalizedUrl == null || normalizedUrl.isEmpty
                ? null
                : _colorSchemeCache.putIfAbsent(
                    normalizedUrl,
                    () => _extractColorScheme(normalizedUrl),
                  ),
        builder: (context, snapshot) {
          final colorScheme = snapshot.data;
          final colors = logoDesign == null && colorScheme != null
              ? (colorScheme.primary, colorScheme.tertiary)
              : (
                  logoDesign?.color ?? fallbackColors.$1,
                  logoDesign == null
                      ? fallbackColors.$2
                      : Color.lerp(
                          logoDesign!.color, AppColors.of(context).white, 0.78)!
                );

          return CustomPaint(
            size: Size.square(radius * 2),
            painter: _TeamBadgePainter(
              white: AppColors.of(context).white,
              primary: colors.$1,
              secondary: colors.$2,
              pattern: seed % 4,
              shape: logoDesign?.shape ?? TeamLogoShape.circle,
              logoPattern: logoDesign?.pattern,
            ),
            child: SizedBox.square(
              dimension: radius * 2,
              child: Center(
                child: Text(
                  _initials(teamName),
                  style: appTextStyles.buttonTiny.copyWith(
                    color: AppColors.of(context).white,
                    fontSize: radius * 0.72,
                    fontWeight: FontWeight.w700,
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

class TeamLogoShapeBorder extends ShapeBorder {
  final TeamLogoShape shape;

  const TeamLogoShapeBorder(this.shape);

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return _logoPath(rect, shape);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return _logoPath(rect, shape);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => this;

  @override
  bool operator ==(Object other) {
    return other is TeamLogoShapeBorder && other.shape == shape;
  }

  @override
  int get hashCode => shape.hashCode;
}

class _TeamBadgePainter extends CustomPainter {
  final Color white;
  final Color primary;
  final Color secondary;
  final int pattern;
  final TeamLogoShape shape;
  final TeamLogoPattern? logoPattern;

  const _TeamBadgePainter({
    required this.white,
    required this.primary,
    required this.secondary,
    required this.pattern,
    required this.shape,
    required this.logoPattern,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    final center = bounds.center;
    final radius = size.shortestSide / 2;
    final logoPath = TeamLogoShapeBorder(shape).getOuterPath(bounds);

    canvas.save();
    canvas.clipPath(logoPath);

    final secondaryPaint = Paint()..color = secondary;
    final stripePaint = Paint()
      ..color = white.withValues(alpha: 0.34)
      ..strokeWidth = math.max(2, size.width * 0.14);

    if (logoPattern != null) {
      final fillPaint = Paint();
      switch (logoPattern!) {
        case TeamLogoPattern.solid:
          fillPaint.color = primary;
        case TeamLogoPattern.verticalSplit:
          fillPaint.shader = LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [primary, primary, secondary, secondary],
            stops: const [0, 0.5, 0.5, 1],
          ).createShader(bounds);
        case TeamLogoPattern.horizontalSplit:
          fillPaint.shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [primary, primary, secondary, secondary],
            stops: const [0, 0.5, 0.5, 1],
          ).createShader(bounds);
        case TeamLogoPattern.gradient:
          fillPaint.shader = LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [primary, white],
          ).createShader(bounds);
      }
      canvas.drawRect(bounds, fillPaint);
    } else {
      canvas.drawColor(primary, BlendMode.src);
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
              ..color = white.withValues(alpha: 0.34)
              ..style = PaintingStyle.stroke
              ..strokeWidth = math.max(2, size.width * 0.1),
          );
      }
    }

    canvas.restore();
    canvas.drawPath(
      logoPath,
      Paint()
        ..color = white.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant _TeamBadgePainter oldDelegate) =>
      oldDelegate.white != white ||
      oldDelegate.primary != primary ||
      oldDelegate.secondary != secondary ||
      oldDelegate.pattern != pattern ||
      oldDelegate.shape != shape ||
      oldDelegate.logoPattern != logoPattern;
}

Path _logoPath(Rect bounds, TeamLogoShape shape) {
  final size = bounds.shortestSide;
  final radius = Radius.circular(size * 0.14);

  return switch (shape) {
    TeamLogoShape.circle => Path()..addOval(bounds),
    TeamLogoShape.square => Path()
      ..addRRect(RRect.fromRectAndRadius(bounds, radius)),
    TeamLogoShape.shield => Path()
      ..addRRect(
        RRect.fromRectAndCorners(
          bounds,
          topLeft: radius,
          topRight: radius,
          bottomLeft: Radius.circular(size * 0.28),
          bottomRight: Radius.circular(size * 0.28),
        ),
      ),
    TeamLogoShape.rounded => Path()
      ..addRRect(RRect.fromRectAndRadius(bounds, Radius.circular(size * 0.22))),
  };
}

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
