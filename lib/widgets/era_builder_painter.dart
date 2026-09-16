import 'dart:math' as math;

import 'package:flutter/material.dart';

class EraBuilderPainter extends CustomPainter {
  final int stage; // 1: Stone Age, 2: Timber Age, 3: Iron Age, 4: Castle Age, 5: Imperial Age
  final double animValue;

  EraBuilderPainter({required this.stage, required this.animValue});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2 + 4;

    // Ground Drop Shadow
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 28), width: 44, height: 12),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    // Continuous Hammer Arm Swing Angle (-0.6 to +0.6 radians)
    final swingProgress = math.sin(animValue * 2 * math.pi * 3);
    final armAngle = swingProgress * 0.55;
    final isHitting = swingProgress < -0.7; // Impact flash on hit!

    switch (stage) {
      case 1:
        _drawStoneAgeCaveman(canvas, size, cx, cy, armAngle, isHitting);
        break;
      case 2:
        _drawTimberCarpenter(canvas, size, cx, cy, armAngle, isHitting);
        break;
      case 3:
        _drawIronAgeBlacksmith(canvas, size, cx, cy, armAngle, isHitting);
        break;
      case 4:
        _drawCastleStonemason(canvas, size, cx, cy, armAngle, isHitting);
        break;
      case 5:
        _drawImperialArchitect(canvas, size, cx, cy, armAngle, isHitting);
        break;
      default:
        _drawIronAgeBlacksmith(canvas, size, cx, cy, armAngle, isHitting);
    }
  }

  // --- 1. STONE AGE CAVEMAN BUILDER (Animal Pelt, Feather, Stone Mallet) ---
  void _drawStoneAgeCaveman(
    Canvas canvas,
    Size size,
    double cx,
    double cy,
    double armAngle,
    bool isHitting,
  ) {
    // Stone Boulder Anvil
    final anvilPath = Path()
      ..moveTo(cx - 24, cy + 12)
      ..lineTo(cx - 10, cy + 12)
      ..lineTo(cx - 14, cy + 24)
      ..lineTo(cx - 20, cy + 24)
      ..close();
    canvas.drawPath(
      anvilPath,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF94A3B8), Color(0xFF475569)],
        ).createShader(anvilPath.getBounds()),
    );

    // Body: Leopard/Fur Pelt Tunic with 3D Gradient
    final tunicRect = Rect.fromLTWH(cx - 10, cy - 2, 20, 22);
    canvas.drawRRect(
      RRect.fromRectAndRadius(tunicRect, const Radius.circular(5)),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF59E0B), Color(0xFFB45309)],
        ).createShader(tunicRect),
    );
    // Pelt Spots
    canvas.drawCircle(
      Offset(cx - 4, cy + 6),
      2,
      Paint()..color = const Color(0xFF451A03),
    );
    canvas.drawCircle(
      Offset(cx + 4, cy + 14),
      2,
      Paint()..color = const Color(0xFF451A03),
    );

    // Legs & Fur Wraps
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 8, cy + 20, 6, 8),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF78350F),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx + 2, cy + 20, 6, 8),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF78350F),
    );

    // Head & Expressive Face
    _drawCharacterHead(
      canvas,
      cx,
      cy - 12,
      skinColor: const Color(0xFFFDBA74),
      hairColor: const Color(0xFF451A03),
      hasHeadband: true,
      headbandColor: const Color(0xFFEF4444),
    );

    // Swinging Arm holding Stone Mallet 🪨
    canvas.save();
    canvas.translate(cx - 6, cy - 2);
    canvas.rotate(armAngle - 0.4);

    // Arm Muscle
    canvas.drawLine(
      Offset.zero,
      const Offset(-12, 4),
      Paint()
        ..color = const Color(0xFFFDBA74)
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );
    // Wooden Handle
    canvas.drawLine(
      const Offset(-12, 4),
      const Offset(-20, -14),
      Paint()
        ..color = const Color(0xFF78350F)
        ..strokeWidth = 3.5,
    );
    // Textured Stone Head
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-26, -20, 12, 12),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFF64748B),
    );
    canvas.restore();

    // Dust Puffs
    if (isHitting) {
      canvas.drawCircle(
        Offset(cx - 18, cy + 12),
        6,
        Paint()..color = Colors.white70,
      );
    }
  }

  // --- 2. TIMBER AGE CARPENTER (Leather Apron, Wood Mallet) ---
  void _drawTimberCarpenter(
    Canvas canvas,
    Size size,
    double cx,
    double cy,
    double armAngle,
    bool isHitting,
  ) {
    // Scaffold Timber Log
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 24, cy + 14, 18, 10),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFFB45309),
    );

    // Body: Green Tunic + Leather Apron
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 10, cy - 2, 20, 22),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF15803D),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 7, cy + 2, 14, 18),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFF78350F),
    );

    // Boots
    canvas.drawRect(
      Rect.fromLTWH(cx - 7, cy + 20, 5, 8),
      Paint()..color = const Color(0xFF451A03),
    );
    canvas.drawRect(
      Rect.fromLTWH(cx + 2, cy + 20, 5, 8),
      Paint()..color = const Color(0xFF451A03),
    );

    // Head
    _drawCharacterHead(
      canvas,
      cx,
      cy - 12,
      skinColor: const Color(0xFFFED7AA),
      hairColor: const Color(0xFF92400E),
      hasCap: true,
    );

    // Swinging Arm holding Wooden Mallet 🪵
    canvas.save();
    canvas.translate(cx - 6, cy);
    canvas.rotate(armAngle - 0.3);

    canvas.drawLine(
      Offset.zero,
      const Offset(-12, 4),
      Paint()
        ..color = const Color(0xFFFED7AA)
        ..strokeWidth = 4.5
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      const Offset(-12, 4),
      const Offset(-18, -12),
      Paint()
        ..color = const Color(0xFF451A03)
        ..strokeWidth = 3.5,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-24, -16, 12, 9),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFFB45309),
    );
    canvas.restore();

    if (isHitting) {
      canvas.drawCircle(
        Offset(cx - 16, cy + 12),
        3,
        Paint()..color = const Color(0xFFFDE047),
      );
    }
  }

  // --- 3. HIGH-RES 2D HEROIC IRON AGE BLACKSMITH (Smithy Apron, Steel Hammer, Anvil Sparks) ---
  void _drawIronAgeBlacksmith(
    Canvas canvas,
    Size size,
    double cx,
    double cy,
    double armAngle,
    bool isHitting,
  ) {
    // 3D Metallic Iron Anvil
    final anvilPath = Path()
      ..moveTo(cx - 28, cy + 12)
      ..lineTo(cx - 10, cy + 12)
      ..lineTo(cx - 13, cy + 24)
      ..lineTo(cx - 23, cy + 24)
      ..close();
    canvas.drawPath(
      anvilPath,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF64748B), Color(0xFF334155), Color(0xFF0F172A)],
        ).createShader(anvilPath.getBounds()),
    );
    // Anvil Top Metal Shine
    canvas.drawLine(
      Offset(cx - 27, cy + 13),
      Offset(cx - 11, cy + 13),
      Paint()
        ..color = const Color(0xFF94A3B8)
        ..strokeWidth = 2,
    );

    // Body: Dark Smithy Vest & Brown Leather Apron with Brass Buckle
    final torsoRect = Rect.fromLTWH(cx - 11, cy - 3, 22, 24);
    canvas.drawRRect(
      RRect.fromRectAndRadius(torsoRect, const Radius.circular(5)),
      Paint()..color = const Color(0xFF1E293B),
    );
    final apronRect = Rect.fromLTWH(cx - 8, cy + 1, 16, 20);
    canvas.drawRRect(
      RRect.fromRectAndRadius(apronRect, const Radius.circular(3)),
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF92400E), Color(0xFF78350F)],
        ).createShader(apronRect),
    );
    // Belt & Brass Buckle
    canvas.drawRect(
      Rect.fromLTWH(cx - 8, cy + 10, 16, 3),
      Paint()..color = const Color(0xFF451A03),
    );
    canvas.drawRect(
      Rect.fromLTWH(cx - 3, cy + 9, 6, 5),
      Paint()..color = const Color(0xFFFACC15),
    );

    // Legs & Heavy Smithy Boots
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 8, cy + 21, 6, 8),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF0F172A),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx + 2, cy + 21, 6, 8),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF0F172A),
    );

    // Head with Smithy Bandana & Goggles
    _drawCharacterHead(
      canvas,
      cx,
      cy - 13,
      skinColor: const Color(0xFFFDBA74),
      hairColor: const Color(0xFF1E293B),
      hasGoggles: true,
    );

    // Muscular Arm Swinging Heavy Steel Sledgehammer ⚒️
    canvas.save();
    canvas.translate(cx - 7, cy - 2);
    canvas.rotate(armAngle - 0.45);

    // Arm
    canvas.drawLine(
      Offset.zero,
      const Offset(-13, 5),
      Paint()
        ..color = const Color(0xFFFDBA74)
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round,
    );
    // Steel Shaft
    canvas.drawLine(
      const Offset(-13, 5),
      const Offset(-22, -16),
      Paint()
        ..color = const Color(0xFF475569)
        ..strokeWidth = 4,
    );
    // 3D Metallic Hammer Head
    final hammerHead = Rect.fromLTWH(-28, -22, 14, 12);
    canvas.drawRRect(
      RRect.fromRectAndRadius(hammerHead, const Radius.circular(2)),
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFCBD5E1), Color(0xFF64748B), Color(0xFF334155)],
        ).createShader(hammerHead),
    );
    canvas.restore();

    // BRIGHT SPARK ARCS & FIERY IMPACT GLOW 💥
    if (isHitting) {
      // Heat Glow
      canvas.drawCircle(
        Offset(cx - 19, cy + 12),
        14,
        Paint()
          ..color = const Color(0xFFEF4444).withValues(alpha: 0.5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
      // Spark Lines
      final sparkPaint = Paint()
        ..color = const Color(0xFFFACC15)
        ..strokeWidth = 2;
      canvas.drawLine(
        Offset(cx - 19, cy + 12),
        Offset(cx - 28, cy + 4),
        sparkPaint,
      );
      canvas.drawLine(
        Offset(cx - 19, cy + 12),
        Offset(cx - 12, cy + 2),
        sparkPaint,
      );
      canvas.drawLine(
        Offset(cx - 19, cy + 12),
        Offset(cx - 24, cy + 20),
        sparkPaint,
      );
      canvas.drawCircle(
        Offset(cx - 19, cy + 12),
        4,
        Paint()..color = Colors.white,
      );
    }
  }

  // --- 4. CASTLE AGE STONEMASON ---
  void _drawCastleStonemason(
    Canvas canvas,
    Size size,
    double cx,
    double cy,
    double armAngle,
    bool isHitting,
  ) {
    // Cut Stone Block
    final stoneBlock = Rect.fromLTWH(cx - 26, cy + 12, 18, 12);
    canvas.drawRect(stoneBlock, Paint()..color = const Color(0xFF64748B));

    // Body: Royal Blue Tunic
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 10, cy - 2, 20, 22),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF2563EB),
    );

    // Boots
    canvas.drawRect(
      Rect.fromLTWH(cx - 7, cy + 20, 5, 8),
      Paint()..color = const Color(0xFF1E293B),
    );
    canvas.drawRect(
      Rect.fromLTWH(cx + 2, cy + 20, 5, 8),
      Paint()..color = const Color(0xFF1E293B),
    );

    // Head
    _drawCharacterHead(
      canvas,
      cx,
      cy - 12,
      skinColor: const Color(0xFFFED7AA),
      hairColor: const Color(0xFF1E3A8A),
      hasHood: true,
    );

    // Arm holding Mason Hammer
    canvas.save();
    canvas.translate(cx - 6, cy);
    canvas.rotate(armAngle - 0.4);
    canvas.drawLine(
      Offset.zero,
      const Offset(-12, 4),
      Paint()
        ..color = const Color(0xFFFED7AA)
        ..strokeWidth = 4.5,
    );
    canvas.drawLine(
      const Offset(-12, 4),
      const Offset(-18, -14),
      Paint()
        ..color = const Color(0xFF451A03)
        ..strokeWidth = 3.5,
    );
    canvas.drawRect(
      Rect.fromLTWH(-24, -18, 12, 10),
      Paint()..color = const Color(0xFF475569),
    );
    canvas.restore();

    if (isHitting) {
      canvas.drawCircle(
        Offset(cx - 18, cy + 12),
        4,
        Paint()..color = Colors.white,
      );
    }
  }

  // --- 5. IMPERIAL ARCHITECT ---
  void _drawImperialArchitect(
    Canvas canvas,
    Size size,
    double cx,
    double cy,
    double armAngle,
    bool isHitting,
  ) {
    // Gold Robe Body
    final robePath = Path()
      ..moveTo(cx - 10, cy - 4)
      ..lineTo(cx + 10, cy - 4)
      ..lineTo(cx + 14, cy + 24)
      ..lineTo(cx - 14, cy + 24)
      ..close();
    canvas.drawPath(robePath, Paint()..color = const Color(0xFF7E22CE));

    // Head with Crown
    _drawCharacterHead(
      canvas,
      cx,
      cy - 14,
      skinColor: const Color(0xFFFDE047),
      hairColor: const Color(0xFFFACC15),
      hasCrown: true,
    );

    // Arm holding Scepter
    canvas.save();
    canvas.translate(cx - 6, cy - 2);
    canvas.rotate(armAngle - 0.3);
    canvas.drawLine(
      Offset.zero,
      const Offset(-12, 4),
      Paint()
        ..color = const Color(0xFFFDE047)
        ..strokeWidth = 4.5,
    );
    canvas.drawLine(
      const Offset(-12, 4),
      const Offset(-18, -16),
      Paint()
        ..color = const Color(0xFFFACC15)
        ..strokeWidth = 3.5,
    );
    canvas.drawCircle(
      const Offset(-18, -16),
      6,
      Paint()..color = const Color(0xFFEAB308),
    );
    canvas.restore();

    if (isHitting) {
      canvas.drawCircle(
        Offset(cx - 18, cy + 8),
        5,
        Paint()..color = const Color(0xFF38BDF8),
      );
    }
  }

  // --- HELPER TO DRAW POLISHED 2D CHARACTER HEAD & FACE ---
  void _drawCharacterHead(
    Canvas canvas,
    double cx,
    double cy, {
    required Color skinColor,
    required Color hairColor,
    bool hasHeadband = false,
    Color headbandColor = Colors.red,
    bool hasCap = false,
    bool hasGoggles = false,
    bool hasHood = false,
    bool hasCrown = false,
  }) {
    // Head Base
    canvas.drawCircle(Offset(cx, cy), 10, Paint()..color = skinColor);

    // Expressive Eyes with White Pupil Highlights
    final eyePaint = Paint()..color = const Color(0xFF0F172A);
    canvas.drawCircle(Offset(cx - 3.5, cy - 1), 2.0, eyePaint);
    canvas.drawCircle(Offset(cx + 3.5, cy - 1), 2.0, eyePaint);
    canvas.drawCircle(
      Offset(cx - 4.0, cy - 1.5),
      0.8,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      Offset(cx + 3.0, cy - 1.5),
      0.8,
      Paint()..color = Colors.white,
    );

    // Smiling Mouth
    final mouthPath = Path()
      ..addArc(Rect.fromLTWH(cx - 3, cy + 2, 6, 4), 0, math.pi);
    canvas.drawPath(
      mouthPath,
      Paint()
        ..color = const Color(0xFF991B1B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // Hair / Headwear Details
    if (hasGoggles) {
      // Black Smithy Bandana & Goggles
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy - 2), radius: 10.5),
        math.pi,
        math.pi,
        true,
        Paint()..color = hairColor,
      );
      // Goggles Rim
      canvas.drawCircle(
        Offset(cx - 4, cy - 4),
        3.5,
        Paint()..color = const Color(0xFFFACC15),
      );
      canvas.drawCircle(
        Offset(cx + 4, cy - 4),
        3.5,
        Paint()..color = const Color(0xFFFACC15),
      );
      canvas.drawCircle(
        Offset(cx - 4, cy - 4),
        2.0,
        Paint()..color = const Color(0xFF1E293B),
      );
      canvas.drawCircle(
        Offset(cx + 4, cy - 4),
        2.0,
        Paint()..color = const Color(0xFF1E293B),
      );
    } else if (hasHeadband) {
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy - 2), radius: 10.5),
        math.pi,
        math.pi,
        true,
        Paint()..color = hairColor,
      );
      canvas.drawLine(
        Offset(cx - 10, cy - 3),
        Offset(cx + 10, cy - 3),
        Paint()
          ..color = headbandColor
          ..strokeWidth = 2.5,
      );
    } else if (hasCap) {
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy - 2), radius: 11),
        math.pi,
        math.pi,
        true,
        Paint()..color = hairColor,
      );
    } else if (hasHood) {
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy - 2), radius: 11),
        math.pi,
        math.pi,
        true,
        Paint()..color = hairColor,
      );
    } else if (hasCrown) {
      canvas.drawCircle(
        Offset(cx, cy - 12),
        4,
        Paint()..color = const Color(0xFFFACC15),
      );
    }
  }

  @override
  bool shouldRepaint(covariant EraBuilderPainter oldDelegate) =>
      oldDelegate.stage != stage || oldDelegate.animValue != animValue;
}
