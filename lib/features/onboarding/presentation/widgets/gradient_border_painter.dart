import 'package:flutter/material.dart';

class GradientBorderPainter extends CustomPainter {
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;

  GradientBorderPainter({required this.backgroundColor, required this.borderColor, required this.borderWidth, this.borderRadius = 0.0});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final backgroundPaint =
        Paint()
          ..color = backgroundColor
          ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius - borderWidth, backgroundPaint);

    final gradientPaint =
        Paint()
          ..shader = RadialGradient(
            center: Alignment.topLeft,
            radius: 1.0,
            colors: [
              Colors.white.withValues(alpha: 0.9),
              Colors.white.withValues(alpha: 0.2),
              Colors.white.withValues(alpha: 0.1),
              Colors.white.withValues(alpha: 0.1),
            ],
            stops: const [0.2, 0.4, 0.7, 1.0],
          ).createShader(Rect.fromCircle(center: center, radius: radius))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8;

    canvas.drawCircle(center, radius - borderWidth / 2, gradientPaint);

    final shadowPaint =
        Paint()
          ..shader = RadialGradient(
            center: Alignment.bottomRight,
            radius: 0.4,
            colors: [Colors.black.withValues(alpha: 0.08), Colors.transparent],
            stops: const [0.0, 1.0],
          ).createShader(Rect.fromCircle(center: center, radius: radius))
          ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius - borderWidth, shadowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class RoundedGradientBorderPainter extends CustomPainter {
  final Color backgroundColor;
  final double borderRadius;

  RoundedGradientBorderPainter({required this.backgroundColor, required this.borderRadius});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rRect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    final backgroundPaint =
        Paint()
          ..color = backgroundColor
          ..style = PaintingStyle.fill;
    canvas.drawRRect(rRect, backgroundPaint);

    final gradientPaint =
        Paint()
          ..shader = RadialGradient(
            center: Alignment.topLeft,
            radius: 2.0,
            colors: [
              Colors.white.withValues(alpha: 1),
              Colors.white.withValues(alpha: 0.4),
              Colors.white.withValues(alpha: 0.4),
              Colors.white.withValues(alpha: 0.4),
            ],
            stops: const [0.015, 0.03, 0.7, 1.0],
          ).createShader(rect)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8;

    canvas.drawRRect(rRect, gradientPaint);

    final shadowPaint =
        Paint()
          ..shader = RadialGradient(
            center: Alignment.bottomRight,
            radius: 0.4,
            colors: [Colors.black.withValues(alpha: 0.08), Colors.transparent],
            stops: const [0.0, 1.0],
          ).createShader(rect)
          ..style = PaintingStyle.fill;

    canvas.drawRRect(rRect, shadowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class WelcomeScreenGradientBorderPainter extends CustomPainter {
  final Color backgroundColor;
  final double borderRadius;

  WelcomeScreenGradientBorderPainter({required this.backgroundColor, required this.borderRadius});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rRect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    final backgroundPaint =
        Paint()
          ..color = backgroundColor
          ..style = PaintingStyle.fill;
    canvas.drawRRect(rRect, backgroundPaint);

    final gradientPaint =
        Paint()
          ..shader = RadialGradient(
            center: Alignment.topLeft,
            radius: 2.0,
            colors: [
              Colors.white.withValues(alpha: 1.0),
              Colors.white.withValues(alpha: 0.4),
              Colors.white.withValues(alpha: 0.25),
              Colors.white.withValues(alpha: 0.2),
            ],
            stops: const [0.05, 0.3, 0.5, 1.0],
          ).createShader(rect)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;

    canvas.drawRRect(rRect, gradientPaint);

    final shadowPaint =
        Paint()
          ..shader = RadialGradient(
            center: Alignment.bottomRight,
            radius: 0.4,
            colors: [Colors.black.withValues(alpha: 0.08), Colors.transparent],
            stops: const [0.0, 1.0],
          ).createShader(rect)
          ..style = PaintingStyle.fill;

    canvas.drawRRect(rRect, shadowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
