import 'dart:math' as math;

import 'package:flutter/material.dart';

class MapPathPainter extends CustomPainter {
  final List<Offset> nodePositions;
  final int activeIndex;
  final Color pathColor;

  MapPathPainter({
    required this.nodePositions,
    required this.activeIndex,
    required this.pathColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (nodePositions.length < 2) return;

    final path = Path();
    path.moveTo(nodePositions[0].dx, nodePositions[0].dy);

    for (int i = 0; i < nodePositions.length - 1; i++) {
      final p1 = nodePositions[i];
      final p2 = nodePositions[i + 1];

      // Smooth S-curve control points matching the sandy trail curves
      final controlY1 = p1.dy + (p2.dy - p1.dy) * 0.5;
      final controlY2 = p1.dy + (p2.dy - p1.dy) * 0.5;

      path.cubicTo(p1.dx, controlY1, p2.dx, controlY2, p2.dx, p2.dy);
    }

    // 1. ROPE GROUND SHADOW (Gives 3D depth and elevation over terrain)
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0x66261505)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    // 2. DARK HEMP ROPE OUTER CONTOUR / BORDER
    canvas.drawPath(
      path,
      Paint()
        ..color =
            const Color(0xFF4A2E17) // Dark hemp outline
        ..style = PaintingStyle.stroke
        ..strokeWidth = 11
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // 3. MAIN WARM HEMP BODY (Golden Brown Braided Rope)
    canvas.drawPath(
      path,
      Paint()
        ..color =
            const Color(0xFFC68B45) // Natural golden hemp color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7.5
        ..strokeCap = StrokeCap.round,
    );

    // 4. ROPE HIGHLIGHT CORE (Sunlit Top Edge)
    canvas.drawPath(
      path,
      Paint()
        ..color =
            const Color(0xFFF3C77C) // Light golden straw highlight
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round,
    );

    // 5. BRAIDED TWIST STITCHES ALONG THE PATH METRIC (Twisted Rope Texture)
    final twistDarkPaint = Paint()
      ..color = const Color(0xFF5C3A16)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    final twistHighlightPaint = Paint()
      ..color = const Color(0xFFFFF3D1)
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    for (final metric in path.computeMetrics()) {
      double distance = 0.0;
      const double step = 9.0; // Spacing between spiral twists
      while (distance < metric.length) {
        final tangent = metric.getTangentForOffset(distance);
        if (tangent != null) {
          final pos = tangent.position;
          final angle = tangent.angle;

          // Normal vector perpendicular to path angle
          final normalX = -math.sin(angle);
          final normalY = math.cos(angle);

          // Diagonal twist vector
          final twistX = math.cos(angle + math.pi / 4);
          final twistY = math.sin(angle + math.pi / 4);

          // Draw dark groove line across the rope
          final pStartDark = Offset(
            pos.dx - twistX * 4.5,
            pos.dy - twistY * 4.5,
          );
          final pEndDark = Offset(pos.dx + twistX * 4.5, pos.dy + twistY * 4.5);
          canvas.drawLine(pStartDark, pEndDark, twistDarkPaint);

          // Offset highlight stitch for 3D braided look
          final pStartHi = Offset(
            pos.dx - twistX * 3.0 + normalX * 1.2,
            pos.dy - twistY * 3.0 + normalY * 1.2,
          );
          final pEndHi = Offset(
            pos.dx + twistX * 2.0 + normalX * 1.2,
            pos.dy + twistY * 2.0 + normalY * 1.2,
          );
          canvas.drawLine(pStartHi, pEndHi, twistHighlightPaint);
        }
        distance += step;
      }
    }

    // 6. RUSTIC WOODEN ANCHOR STAKES AT LEVEL NODE CONNECTORS
    final stakeWoodPaint = Paint()..color = const Color(0xFF5C3A16);
    final stakeRingPaint = Paint()..color = const Color(0xFFD7A15C);
    for (final pos in nodePositions) {
      canvas.drawCircle(pos, 9, stakeWoodPaint);
      canvas.drawCircle(pos, 6, stakeRingPaint);
      canvas.drawCircle(pos, 3, stakeWoodPaint);
    }
  }

  @override
  bool shouldRepaint(covariant MapPathPainter oldDelegate) =>
      oldDelegate.activeIndex != activeIndex ||
      oldDelegate.pathColor != pathColor;
}
