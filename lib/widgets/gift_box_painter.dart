import 'dart:math' as math;

import 'package:flutter/material.dart';

class GiftBoxPainter extends CustomPainter {
  final bool isOpen;
  final double openProgress; // 0.0 to 1.0

  GiftBoxPainter({required this.isOpen, this.openProgress = 0.0});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2 + 10;

    // 1. Ground Drop Shadow
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 28), width: 90, height: 22),
      Paint()..color = Colors.black.withValues(alpha: 0.3),
    );

    // 2. Glowing Golden Light Rays (when opening)
    if (isOpen) {
      final lightPaint = Paint()
        ..shader =
            RadialGradient(
              colors: [
                const Color(0xFFFDE047).withValues(alpha: 0.7 * openProgress),
                const Color(0xFFFACC15).withValues(alpha: 0.3 * openProgress),
                Colors.transparent,
              ],
            ).createShader(
              Rect.fromCircle(center: Offset(cx, cy - 15), radius: 70),
            );

      canvas.drawCircle(Offset(cx, cy - 15), 75, lightPaint);
    }

    // 3. Wooden Chest Body Base (Mahogany Wood)
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - 36, cy - 10, 72, 38),
      const Radius.circular(8),
    );
    canvas.drawRRect(bodyRect, Paint()..color = const Color(0xFF78350F));

    // 4. OVERFLOWING TREASURE PILE INSIDE CHEST (GOLD COINS & GEMS!)
    if (isOpen) {
      // Inner Chest Dark Depth
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(cx - 32, cy - 14, 64, 20),
          const Radius.circular(6),
        ),
        Paint()..color = const Color(0xFF451A03),
      );

      // Overflowing Gold Coins Pile
      final goldCoinPaint = Paint()..color = const Color(0xFFFACC15);
      final goldGleamPaint = Paint()..color = const Color(0xFFFEF3C7);
      final gemPurplePaint = Paint()..color = const Color(0xFFA855F7);
      final gemCyanPaint = Paint()..color = const Color(0xFF38BDF8);

      final rng = math.Random(42);
      for (int i = 0; i < 24; i++) {
        final dx = cx - 26 + (rng.nextDouble() * 52);
        final dy = cy - 16 + (rng.nextDouble() * 14) - (openProgress * 6);
        final r = 3.5 + (rng.nextDouble() * 3.5);

        if (i % 7 == 0) {
          // Gem
          canvas.drawCircle(Offset(dx, dy), r * 1.1, gemPurplePaint);
        } else if (i % 9 == 0) {
          // Gem
          canvas.drawCircle(Offset(dx, dy), r * 1.1, gemCyanPaint);
        } else {
          // Gold Coin
          canvas.drawCircle(Offset(dx, dy), r, goldCoinPaint);
          canvas.drawCircle(Offset(dx - 1, dy - 1), r * 0.4, goldGleamPaint);
        }
      }
    }

    // Chest Body Outline
    canvas.drawRRect(
      bodyRect,
      Paint()
        ..color = const Color(0xFF451A03)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // Gold Corner Brackets & Rivets
    final goldPaint = Paint()..color = const Color(0xFFFACC15);
    final goldBorderPaint = Paint()
      ..color = const Color(0xFFB45309)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Corner bands
    canvas.drawRect(Rect.fromLTWH(cx - 36, cy - 10, 10, 38), goldPaint);
    canvas.drawRect(Rect.fromLTWH(cx + 26, cy - 10, 10, 38), goldPaint);
    canvas.drawRect(Rect.fromLTWH(cx - 36, cy - 10, 10, 38), goldBorderPaint);
    canvas.drawRect(Rect.fromLTWH(cx + 26, cy - 10, 10, 38), goldBorderPaint);

    // Center Gold Lock Plate
    final lockRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - 8, cy + 2, 16, 16),
      const Radius.circular(4),
    );
    canvas.drawRRect(lockRect, goldPaint);
    canvas.drawRRect(lockRect, goldBorderPaint);
    // Keyhole
    canvas.drawCircle(
      Offset(cx, cy + 8),
      3,
      Paint()..color = const Color(0xFF451A03),
    );

    // 5. Chest Lid (Arched Top)
    canvas.save();
    canvas.translate(cx - 38, cy - 10);

    if (isOpen) {
      // Rotate lid backward to open
      final lidAngle = -0.75 * openProgress;
      canvas.rotate(lidAngle);
    }

    final lidPath = Path()
      ..moveTo(0, 0)
      ..cubicTo(0, -22, 76, -22, 76, 0)
      ..close();

    canvas.drawPath(lidPath, Paint()..color = const Color(0xFF92400E));
    canvas.drawPath(
      lidPath,
      Paint()
        ..color = const Color(0xFF451A03)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // Gold Lid Rim Band
    canvas.drawRect(const Rect.fromLTWH(0, -4, 76, 5), goldPaint);
    canvas.drawRect(const Rect.fromLTWH(0, -4, 76, 5), goldBorderPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant GiftBoxPainter oldDelegate) =>
      oldDelegate.isOpen != isOpen || oldDelegate.openProgress != openProgress;
}

// --- REAL 2D VECTOR REWARD ICONS (STARS, COINS, GEMS) ---

class VectorStarWidget extends StatelessWidget {
  final double size;
  final bool isFilled;

  const VectorStarWidget({super.key, this.size = 36, this.isFilled = true});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _VectorStarPainter(isFilled: isFilled),
    );
  }
}

class _VectorStarPainter extends CustomPainter {
  final bool isFilled;

  _VectorStarPainter({required this.isFilled});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final outerR = size.width / 2;
    final innerR = outerR * 0.42;

    final starPath = Path();
    for (int i = 0; i < 10; i++) {
      final r = i.isEven ? outerR : innerR;
      final angle = (i * math.pi / 5) - (math.pi / 2);
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);
      if (i == 0) {
        starPath.moveTo(x, y);
      } else {
        starPath.lineTo(x, y);
      }
    }
    starPath.close();

    if (isFilled) {
      final gradient = RadialGradient(
        colors: const [Color(0xFFFDE047), Color(0xFFEAB308), Color(0xFFCA8A04)],
      );
      canvas.drawPath(
        starPath,
        Paint()..shader = gradient.createShader(Offset.zero & size),
      );
      canvas.drawPath(
        starPath,
        Paint()
          ..color = const Color(0xFF854D0E)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    } else {
      canvas.drawPath(starPath, Paint()..color = Colors.grey.shade300);
      canvas.drawPath(
        starPath,
        Paint()
          ..color = Colors.grey.shade500
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _VectorStarPainter oldDelegate) =>
      oldDelegate.isFilled != isFilled;
}

class VectorCoinIcon extends StatelessWidget {
  final double size;
  const VectorCoinIcon({super.key, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size(size, size), painter: _VectorCoinPainter());
  }
}

class _VectorCoinPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    final coinGradient = RadialGradient(
      colors: const [Color(0xFFFDE047), Color(0xFFFACC15), Color(0xFFD97706)],
    );
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()..shader = coinGradient.createShader(Offset.zero & size),
    );
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..color = const Color(0xFFB45309)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    canvas.drawCircle(
      Offset(cx, cy),
      r * 0.7,
      Paint()
        ..color = const Color(0xFFCA8A04)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class VectorGemIcon extends StatelessWidget {
  final double size;
  const VectorGemIcon({super.key, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size(size, size), painter: _VectorGemPainter());
  }
}

class _VectorGemPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final gemPath = Path()
      ..moveTo(w * 0.25, 0)
      ..lineTo(w * 0.75, 0)
      ..lineTo(w, h * 0.35)
      ..lineTo(w * 0.5, h)
      ..lineTo(0, h * 0.35)
      ..close();

    final gemGradient = LinearGradient(
      colors: const [Color(0xFFC084FC), Color(0xFFA855F7), Color(0xFF7E22CE)],
    );
    canvas.drawPath(
      gemPath,
      Paint()..shader = gemGradient.createShader(Offset.zero & size),
    );
    canvas.drawPath(
      gemPath,
      Paint()
        ..color = const Color(0xFF581C87)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    final facetPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..strokeWidth = 1.2;
    canvas.drawLine(
      Offset(w * 0.25, 0),
      Offset(w * 0.35, h * 0.35),
      facetPaint,
    );
    canvas.drawLine(
      Offset(w * 0.75, 0),
      Offset(w * 0.65, h * 0.35),
      facetPaint,
    );
    canvas.drawLine(Offset(0, h * 0.35), Offset(w, h * 0.35), facetPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
