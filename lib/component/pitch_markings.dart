import 'package:flutter/material.dart';

/// Faint pitch markings on the mint match bands (home and match details): a
/// corner arc growing from the top-right of the screen, and optionally the
/// halfway line with the centre circle at the bottom, where the hero card
/// covers most of them.
///
/// The home band is painted in two pieces, the app bar and the countdown
/// below it. Give each piece its distance from the top of the screen as
/// [topOffset] so the arc continues across the seam.
class PitchMarkingsPainter extends CustomPainter {
  final Color color;
  final double topOffset;
  final bool drawMidfield;

  /// Corner arc radius as a share of the screen width.
  static const double cornerArcWidthFactor = 0.43;

  /// Distance from the bottom of the band to the halfway line.
  static const double halfwayLineInset = 30;
  static const double centreCircleRadius = 50;
  static const double strokeWidth = 2.5;

  const PitchMarkingsPainter({
    required this.color,
    this.topOffset = 0,
    this.drawMidfield = false,
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
    canvas.drawCircle(
      Offset(size.width, -topOffset),
      size.width * cornerArcWidthFactor,
      paint,
    );

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

  @override
  bool shouldRepaint(PitchMarkingsPainter oldDelegate) =>
      color != oldDelegate.color ||
      topOffset != oldDelegate.topOffset ||
      drawMidfield != oldDelegate.drawMidfield;
}
