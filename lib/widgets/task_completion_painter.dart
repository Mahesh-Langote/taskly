import 'package:flutter/material.dart';
import 'dart:math' as math;

class TaskCompletionPainter extends CustomPainter {
  final int completed;
  final int pending;
  final Color completedColor;
  final Color pendingColor;
  final Color textColor;

  TaskCompletionPainter({
    required this.completed,
    required this.pending,
    this.completedColor = Colors.teal,
    this.pendingColor = Colors.orange,
    required this.textColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2) - 20;
    final total = completed + pending;

    if (total == 0) return;

    final completedAngle = 2 * math.pi * completed / total;
    final pendingAngle = 2 * math.pi * pending / total;

    // Create gradient paints for better visual appeal
    final completedPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          completedColor.withOpacity(0.8),
          completedColor,
        ],
        stops: const [0.4, 1.0],
        center: Alignment.topLeft,
        radius: 1.0,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;

    final pendingPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          pendingColor.withOpacity(0.8),
          pendingColor,
        ],
        stops: const [0.4, 1.0],
        center: Alignment.topRight,
        radius: 1.0,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;

    final backgroundPaint = Paint()
      ..color = Colors.grey.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Draw shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawCircle(center.translate(0, 4), radius, shadowPaint);

    // Draw background circle
    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw arcs with slightly smaller radius for modern look
    final arcRadius = radius * 0.96;

    if (completed > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: arcRadius),
        -math.pi / 2,
        completedAngle,
        true,
        completedPaint,
      );
    }

    if (pending > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: arcRadius),
        -math.pi / 2 + completedAngle,
        pendingAngle,
        true,
        pendingPaint,
      );
    }

    // Draw white circle in center for donut effect with shadow
    final centerCircleRadius = radius * 0.62;
    final centerShadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawCircle(
        center.translate(0, 2), centerCircleRadius, centerShadowPaint);

    final centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, centerCircleRadius, centerPaint);

    // Add text in center
    final percentage = (completed / total * 100).toInt();
    final textSpan = TextSpan(
      text: '$percentage%',
      style: TextStyle(
        color: textColor,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      center - Offset(textPainter.width / 2, textPainter.height / 2),
    );

    final labelSpan = TextSpan(
      text: 'Complete',
      style: TextStyle(
        color: textColor.withOpacity(0.7),
        fontSize: 16,
      ),
    );
    final labelPainter = TextPainter(
      text: labelSpan,
      textDirection: TextDirection.ltr,
    );
    labelPainter.layout();
    labelPainter.paint(
      canvas,
      center - Offset(labelPainter.width / 2, -textPainter.height / 2 + 5),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
