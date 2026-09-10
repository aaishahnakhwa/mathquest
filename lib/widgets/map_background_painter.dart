import 'dart:math' as math;

import 'package:flutter/material.dart';

class MapBackgroundPainter extends CustomPainter {
  final String worldId;
  final int completedLevelsCount;

  MapBackgroundPainter({required this.worldId, this.completedLevelsCount = 0});

  @override
  void paint(Canvas canvas, Size size) {
    switch (worldId) {
      case 'world_2':
        _paintDoubleDigitValleyWorld(canvas, size);
        break;
      case 'world_1':
      default:
        _paintHandPaintedFantasyMeadow(canvas, size);
        // Village development ONLY in World 1
        _paintDynamicVillageDevelopment(canvas, size);
        break;
    }
  }

  // --- WORLD 1: DYNAMIC VILLAGE DEVELOPMENT ---
  void _paintDynamicVillageDevelopment(Canvas canvas, Size size) {
    if (completedLevelsCount >= 1) {
      _drawTimberHut(canvas, Offset(size.width * 0.48, size.height * 0.09));
      _drawCampfire(canvas, Offset(size.width * 0.56, size.height * 0.10));
    }

    if (completedLevelsCount >= 2) {
      _drawStoneWindmill(canvas, Offset(size.width * 0.06, size.height * 0.18));
    }

    if (completedLevelsCount >= 3) {
      _drawVillageCottages(
        canvas,
        Offset(size.width * 0.22, size.height * 0.53),
      );
      _drawWheatFarm(canvas, Offset(size.width * 0.12, size.height * 0.56));
    }

    if (completedLevelsCount >= 4) {
      _drawRoyalCastle(canvas, Offset(size.width * 0.65, size.height * 0.68));
    }

    if (completedLevelsCount >= 5) {
      _drawVictoryArchway(
        canvas,
        Offset(size.width * 0.30, size.height * 0.85),
      );
      _drawCelebrationBanners(canvas, size);
    }
  }

  // --- WORLD 2: DOUBLE-DIGIT VALLEY FALLBACK ---
  void _paintDoubleDigitValleyWorld(Canvas canvas, Size size) {
    // Mystical Forest Sky Gradient
    final skyGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: const [
        Color(0xFF042F2E), // Dark Teal
        Color(0xFF0D9488), // Teal
        Color(0xFF14B8A6), // Turquoise
        Color(0xFFCCFBF1), // Mint Highlight
      ],
      stops: const [0.0, 0.4, 0.75, 1.0],
    );
    canvas.drawRect(
      Offset.zero & size,
      Paint()..shader = skyGradient.createShader(Offset.zero & size),
    );

    // Distant Forest Canopy Hills
    final hill1 = Path()
      ..moveTo(0, size.height * 0.15)
      ..quadraticBezierTo(
        size.width * 0.4,
        size.height * 0.08,
        size.width * 0.8,
        size.height * 0.17,
      )
      ..quadraticBezierTo(
        size.width * 0.95,
        size.height * 0.2,
        size.width,
        size.height * 0.14,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(hill1, Paint()..color = const Color(0xFF115E59));

    final hill2 = Path()
      ..moveTo(0, size.height * 0.42)
      ..quadraticBezierTo(
        size.width * 0.3,
        size.height * 0.34,
        size.width * 0.7,
        size.height * 0.45,
      )
      ..quadraticBezierTo(
        size.width * 0.9,
        size.height * 0.48,
        size.width,
        size.height * 0.38,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(hill2, Paint()..color = const Color(0xFF0F766E));

    // Pine Trees Layers
    final treePaint = Paint()..color = const Color(0xFF047857);
    final darkTreePaint = Paint()..color = const Color(0xFF064E3B);

    _drawPineTree(
      canvas,
      Offset(size.width * 0.1, size.height * 0.16),
      36,
      darkTreePaint,
    );
    _drawPineTree(
      canvas,
      Offset(size.width * 0.85, size.height * 0.18),
      42,
      darkTreePaint,
    );
    _drawPineTree(
      canvas,
      Offset(size.width * 0.22, size.height * 0.38),
      46,
      treePaint,
    );
    _drawPineTree(
      canvas,
      Offset(size.width * 0.78, size.height * 0.42),
      52,
      treePaint,
    );

    // Glowing Ancient Runestones (World 2 Elements)
    _drawGlowingRunestone(
      canvas,
      Offset(size.width * 0.82, size.height * 0.28),
    );
    _drawGlowingRunestone(
      canvas,
      Offset(size.width * 0.15, size.height * 0.65),
    );

    // Giant Magic Mushrooms
    _drawMagicMushroom(
      canvas,
      Offset(size.width * 0.12, size.height * 0.48),
      const Color(0xFFF43F5E),
    );
    _drawMagicMushroom(
      canvas,
      Offset(size.width * 0.88, size.height * 0.58),
      const Color(0xFF3B82F6),
    );
  }

  // --- HELPER DRAWING METHODS FOR FANTASY WORLDS ---
  void _drawPineTree(
    Canvas canvas,
    Offset pos,
    double treeHeight,
    Paint paint,
  ) {
    final trunkPaint = Paint()..color = const Color(0xFF451A03);
    canvas.drawRect(
      Rect.fromLTWH(pos.dx - 3, pos.dy, 6, treeHeight * 0.4),
      trunkPaint,
    );

    final path = Path()
      ..moveTo(pos.dx - treeHeight * 0.35, pos.dy + 4)
      ..lineTo(pos.dx, pos.dy - treeHeight)
      ..lineTo(pos.dx + treeHeight * 0.35, pos.dy + 4)
      ..close();
    canvas.drawPath(path, paint);
  }

  void _drawGlowingRunestone(Canvas canvas, Offset pos) {
    final stonePaint = Paint()..color = const Color(0xFF334155);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(pos.dx - 10, pos.dy - 20, 20, 36),
        const Radius.circular(5),
      ),
      stonePaint,
    );
    canvas.drawCircle(
      Offset(pos.dx, pos.dy - 6),
      5,
      Paint()..color = const Color(0xFF2DD4BF),
    );
    canvas.drawCircle(
      Offset(pos.dx, pos.dy - 6),
      10,
      Paint()
        ..color = const Color(0xFF2DD4BF).withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
  }

  void _drawMagicMushroom(Canvas canvas, Offset pos, Color capColor) {
    // Stem
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(pos.dx - 4, pos.dy - 2, 8, 14),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFFFEF3C7),
    );
    // Cap
    final capRect = Rect.fromCircle(
      center: Offset(pos.dx, pos.dy - 4),
      radius: 12,
    );
    canvas.drawArc(capRect, math.pi, math.pi, true, Paint()..color = capColor);
    // Dots
    canvas.drawCircle(
      Offset(pos.dx - 4, pos.dy - 8),
      2,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      Offset(pos.dx + 4, pos.dy - 9),
      2,
      Paint()..color = Colors.white,
    );
  }

  // --- BASE HAND-PAINTED FANTASY MEADOW (WORLD 1) ---
  void _paintHandPaintedFantasyMeadow(Canvas canvas, Size size) {
    final skyGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: const [
        Color(0xFF38BDF8),
        Color(0xFF7DD3FC),
        Color(0xFFBAE6FD),
        Color(0xFFFEF3C7),
      ],
      stops: const [0.0, 0.3, 0.7, 1.0],
    );
    canvas.drawRect(
      Offset.zero & size,
      Paint()..shader = skyGradient.createShader(Offset.zero & size),
    );

    final sunCenter = Offset(size.width * 0.82, size.height * 0.05);
    canvas.drawCircle(
      sunCenter,
      50,
      Paint()..color = const Color(0xFFFDE047).withValues(alpha: 0.35),
    );
    canvas.drawCircle(sunCenter, 32, Paint()..color = const Color(0xFFFACC15));

    final distMountains = Path()
      ..moveTo(0, size.height * 0.12)
      ..lineTo(size.width * 0.18, size.height * 0.06)
      ..lineTo(size.width * 0.35, size.height * 0.11)
      ..lineTo(size.width * 0.55, size.height * 0.05)
      ..lineTo(size.width * 0.78, size.height * 0.1)
      ..lineTo(size.width, size.height * 0.07)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(distMountains, Paint()..color = const Color(0xFF93C5FD));

    final hillLayer1 = Path()
      ..moveTo(0, size.height * 0.18)
      ..quadraticBezierTo(
        size.width * 0.3,
        size.height * 0.12,
        size.width * 0.6,
        size.height * 0.19,
      )
      ..quadraticBezierTo(
        size.width * 0.85,
        size.height * 0.24,
        size.width,
        size.height * 0.17,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(hillLayer1, Paint()..color = const Color(0xFF86EFAC));

    final hillLayer2 = Path()
      ..moveTo(0, size.height * 0.42)
      ..quadraticBezierTo(
        size.width * 0.35,
        size.height * 0.34,
        size.width * 0.75,
        size.height * 0.44,
      )
      ..quadraticBezierTo(
        size.width * 0.9,
        size.height * 0.48,
        size.width,
        size.height * 0.39,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(hillLayer2, Paint()..color = const Color(0xFF4ADE80));
  }

  // --- DYNAMIC DEVELOPMENT STRUCTURE DRAWING HELPERS ---
  void _drawTimberHut(Canvas canvas, Offset pos) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(pos.dx - 18, pos.dy - 12, 36, 24),
        const Radius.circular(6),
      ),
      Paint()..color = const Color(0xFF78350F),
    );
    canvas.drawCircle(
      Offset(pos.dx - 6, pos.dy - 2),
      5,
      Paint()..color = const Color(0xFFFDE047),
    );
    final roof = Path()
      ..moveTo(pos.dx - 22, pos.dy - 12)
      ..lineTo(pos.dx, pos.dy - 28)
      ..lineTo(pos.dx + 22, pos.dy - 12)
      ..close();
    canvas.drawPath(roof, Paint()..color = const Color(0xFFD97706));
  }

  void _drawCampfire(Canvas canvas, Offset pos) {
    canvas.drawCircle(pos, 5, Paint()..color = const Color(0xFFEF4444));
    canvas.drawCircle(pos, 3, Paint()..color = const Color(0xFFFACC15));
  }

  void _drawStoneWindmill(Canvas canvas, Offset pos) {
    final towerPath = Path()
      ..moveTo(pos.dx - 16, pos.dy + 32)
      ..lineTo(pos.dx - 12, pos.dy - 16)
      ..lineTo(pos.dx + 12, pos.dy - 16)
      ..lineTo(pos.dx + 16, pos.dy + 32)
      ..close();
    canvas.drawPath(towerPath, Paint()..color = const Color(0xFFCBD5E1));
    canvas.drawArc(
      Rect.fromCircle(center: Offset(pos.dx, pos.dy - 16), radius: 12),
      math.pi,
      math.pi,
      true,
      Paint()..color = const Color(0xFFDC2626),
    );
  }

  void _drawVillageCottages(Canvas canvas, Offset pos) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(pos.dx - 20, pos.dy, 40, 26),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFFFFFBEB),
    );
  }

  void _drawWheatFarm(Canvas canvas, Offset pos) {
    canvas.drawRect(
      Rect.fromLTWH(pos.dx - 24, pos.dy - 12, 48, 24),
      Paint()..color = const Color(0xFFFEF3C7),
    );
  }

  void _drawRoyalCastle(Canvas canvas, Offset pos) {
    canvas.drawRect(
      Rect.fromLTWH(pos.dx - 24, pos.dy - 16, 48, 32),
      Paint()..color = const Color(0xFF475569),
    );
  }

  void _drawVictoryArchway(Canvas canvas, Offset pos) {
    canvas.drawRect(
      Rect.fromLTWH(pos.dx - 24, pos.dy - 30, 8, 30),
      Paint()..color = const Color(0xFFFEF08A),
    );
  }

  void _drawCelebrationBanners(Canvas canvas, Size size) {
    final colors = [
      const Color(0xFFEF4444),
      const Color(0xFFFACC15),
      const Color(0xFF3B82F6),
      const Color(0xFF22C55E),
    ];
    for (int i = 0; i < 8; i++) {
      final x = (i * 0.12 + 0.08) * size.width;
      final y = size.height * 0.06;
      canvas.drawCircle(
        Offset(x, y),
        5,
        Paint()..color = colors[i % colors.length],
      );
    }
  }

  @override
  bool shouldRepaint(covariant MapBackgroundPainter oldDelegate) =>
      oldDelegate.worldId != worldId ||
      oldDelegate.completedLevelsCount != completedLevelsCount;
}
