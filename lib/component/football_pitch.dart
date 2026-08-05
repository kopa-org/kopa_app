import 'package:flutter/material.dart';

class FootballPitch extends StatelessWidget {
  final Widget? child;
  final EdgeInsetsGeometry linePadding;
  final BorderRadius borderRadius;
  final double borderWidth;
  final List<BoxShadow>? boxShadow;

  const FootballPitch({
    super.key,
    this.child,
    this.linePadding = const EdgeInsets.all(12),
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.borderWidth = 1.5,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;

        return Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: const Color(0xFF106E35),
            borderRadius: borderRadius,
            border: Border.all(color: Colors.white, width: borderWidth),
            boxShadow: boxShadow,
          ),
          child: Stack(
            children: [
              for (var i = 0; i < 7; i++)
                Positioned(
                  top: i * height / 7,
                  left: 0,
                  right: 0,
                  height: height / 14,
                  child: ColoredBox(
                    color: const Color(0xFF167E44).withValues(alpha: 0.3),
                  ),
                ),
              Positioned.fill(
                child: Padding(
                  padding: linePadding,
                  child: const CustomPaint(
                    painter: FootballPitchPainter(),
                  ),
                ),
              ),
              if (child != null) Positioned.fill(child: child!),
            ],
          ),
        );
      },
    );
  }
}

class FootballPitchPainter extends CustomPainter {
  const FootballPitchPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.38)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final thinPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawRect(Offset.zero & size, paint);
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width * 0.12,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      3,
      Paint()..color = Colors.white.withValues(alpha: 0.5),
    );
    _drawBoxFromGoalLine(
      canvas,
      size,
      paint,
      width: size.width * 0.44,
      height: size.height * 0.18,
      isTop: true,
    );
    _drawBoxFromGoalLine(
      canvas,
      size,
      thinPaint,
      width: size.width * 0.22,
      height: size.height * 0.07,
      isTop: true,
    );
    _drawBoxFromGoalLine(
      canvas,
      size,
      paint,
      width: size.width * 0.44,
      height: size.height * 0.18,
      isTop: false,
    );
    _drawBoxFromGoalLine(
      canvas,
      size,
      thinPaint,
      width: size.width * 0.22,
      height: size.height * 0.07,
      isTop: false,
    );
  }

  void _drawBoxFromGoalLine(
    Canvas canvas,
    Size size,
    Paint paint, {
    required double width,
    required double height,
    required bool isTop,
  }) {
    final left = (size.width - width) / 2;
    final top = isTop ? 0.0 : size.height - height;

    canvas.drawRect(
      Rect.fromLTWH(left, top, width, height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
