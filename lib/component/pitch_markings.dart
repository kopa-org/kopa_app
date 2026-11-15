import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Faint pitch markings on the mint match bands (home and match details).
///
/// At the top it draws either a corner arc growing from the top-right of the
/// screen, or with [drawPenaltyArea] the lower part of a penalty area: its
/// goal line sits above the screen, so only the box's sides, bottom edge and
/// the D show. Optionally it draws the halfway line with the centre circle at
/// the bottom, where the hero card covers most of them.
///
/// [topOffset] is how far below the top of the screen the canvas starts
/// (negative when it starts above, like the home band that reaches up behind
/// the status bar) so the top markings stay anchored to the screen's top edge.
class PitchMarkingsPainter extends CustomPainter {
  final Color color;
  final double topOffset;
  final bool drawMidfield;
  final bool drawPenaltyArea;

  /// Corner arc radius as a share of the screen width.
  static const double cornerArcWidthFactor = 0.43;

  /// Distance from the bottom of the band to the halfway line.
  static const double halfwayLineInset = 30;
  static const double centreCircleRadius = 50;
  static const double strokeWidth = 2.5;

  /// The penalty area is drawn to FIFA proportions with the screen width as
  /// the pitch width.
  static const double pitchWidthMetres = 68;
  static const double penaltyAreaWidthMetres = 40.32;
  static const double penaltyAreaDepthMetres = 16.5;
  static const double penaltySpotMetres = 11;
  static const double penaltyArcRadiusMetres = 9.15;

  /// How far above the top of the screen the goal line sits. Equal to the
  /// penalty spot distance, so the spot lands on the screen edge and only
  /// the lower third of the box is visible.
  static const double goalLineAboveScreenMetres = penaltySpotMetres;

  const PitchMarkingsPainter({
    required this.color,
    this.topOffset = 0,
    this.drawMidfield = false,
    this.drawPenaltyArea = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..isAntiAlias = true;

    canvas.save();
    canvas.clipRect(Offset.zero & size);

    final screenTop = -topOffset;
    if (drawPenaltyArea) {
      _paintPenaltyArea(canvas, size, paint, screenTop);
    } else {
      canvas.drawCircle(
        Offset(size.width, screenTop),
        size.width * cornerArcWidthFactor,
        paint,
      );
    }

    if (drawMidfield) {
      final lineY = size.height - halfwayLineInset;
      canvas.drawLine(Offset(0, lineY), Offset(size.width, lineY), paint);
      canvas.drawCircle(
        Offset(size.width / 2, lineY),
        centreCircleRadius,
        paint,
      );
    }
    canvas.restore();
  }

  void _paintPenaltyArea(
    Canvas canvas,
    Size size,
    Paint paint,
    double screenTop,
  ) {
    final metre = size.width / pitchWidthMetres;
    final centreX = size.width / 2;
    final goalLineY = screenTop - goalLineAboveScreenMetres * metre;
    final halfWidth = penaltyAreaWidthMetres / 2 * metre;
    final boxBottomY = goalLineY + penaltyAreaDepthMetres * metre;

    // Goal line and goal area are off screen; draw the box as an open
    // U so nothing is painted along the (hidden) goal line.
    canvas.drawPath(
      Path()
        ..moveTo(centreX - halfWidth, goalLineY)
        ..lineTo(centreX - halfWidth, boxBottomY)
        ..lineTo(centreX + halfWidth, boxBottomY)
        ..lineTo(centreX + halfWidth, goalLineY),
      paint,
    );

    // The D: the part of the 9.15 m circle around the spot outside the box.
    final spot = Offset(centreX, goalLineY + penaltySpotMetres * metre);
    final radius = penaltyArcRadiusMetres * metre;
    final dy = boxBottomY - spot.dy;
    final halfAngle = math.acos((dy / radius).clamp(-1.0, 1.0));
    canvas.drawArc(
      Rect.fromCircle(center: spot, radius: radius),
      math.pi / 2 - halfAngle,
      halfAngle * 2,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(PitchMarkingsPainter oldDelegate) =>
      color != oldDelegate.color ||
      topOffset != oldDelegate.topOffset ||
      drawMidfield != oldDelegate.drawMidfield ||
      drawPenaltyArea != oldDelegate.drawPenaltyArea;
}
