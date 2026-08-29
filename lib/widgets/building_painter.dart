import 'dart:math' as math;
import 'package:flutter/material.dart';

class BuildingPainter extends CustomPainter {
  final int stage; // 1: Hut, 2: Windmill, 3: Market, 4: Castle, 5: Monument
  final double animValue;

  BuildingPainter({
    required this.stage,
    this.animValue = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    switch (stage) {
      case 1:
        _drawTimberCottage(canvas, size);
        break;
      case 2:
        _drawStoneWindmill(canvas, size);
        break;
      case 3:
        _drawVillageMarket(canvas, size);
        break;
      case 4:
        _drawRoyalCastle(canvas, size);
        break;
      case 5:
        _drawVictoryMonument(canvas, size);
        break;
    }
  }

  // --- 1. PREMIUM 3D TIMBER COTTAGE & CAMPFIRE ---
  void _drawTimberCottage(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2 + 2;

    // Ground Contact Shadow
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 24), width: 68, height: 20),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Main Log Body with Wood Gradient
    final bodyRect = Rect.fromLTWH(cx - 24, cy - 6, 48, 30);
    final bodyGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: const [Color(0xFF92400E), Color(0xFF78350F), Color(0xFF451A03)],
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, const Radius.circular(6)),
      Paint()..shader = bodyGradient.createShader(bodyRect),
    );

    // Wood Log Horizontal Planks Shading
    final logPaint = Paint()
      ..color = const Color(0xFF291002).withValues(alpha: 0.6)
      ..strokeWidth = 2;
    for (int y = -1; y <= 20; y += 7) {
      canvas.drawLine(Offset(cx - 23, cy + y), Offset(cx + 23, cy + y), logPaint);
    }

    // Glowing Warm Window
    final windowRect = Rect.fromLTWH(cx - 16, cy + 2, 12, 12);
    canvas.drawRRect(
      RRect.fromRectAndRadius(windowRect, const Radius.circular(3)),
      Paint()..color = const Color(0xFFFDE047),
    );
    // Window Light Glow
    canvas.drawCircle(
      Offset(cx - 10, cy + 8),
      12,
      Paint()
        ..color = const Color(0xFFFACC15).withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    // Window Frame
    final framePaint = Paint()
      ..color = const Color(0xFF451A03)
      ..strokeWidth = 2;
    canvas.drawLine(Offset(cx - 10, cy + 2), Offset(cx - 10, cy + 14), framePaint);
    canvas.drawLine(Offset(cx - 16, cy + 8), Offset(cx - 4, cy + 8), framePaint);

    // Polished Oak Door with Brass Knob
    final doorRect = Rect.fromLTWH(cx + 4, cy + 4, 14, 20);
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        doorRect,
        topLeft: const Radius.circular(5),
        topRight: const Radius.circular(5),
      ),
      Paint()..color = const Color(0xFF3B1705),
    );
    canvas.drawCircle(Offset(cx + 15, cy + 14), 2, Paint()..color = const Color(0xFFFACC15));

    // Thatched Roof with Gradient & Straw Texture
    final roof = Path()
      ..moveTo(cx - 29, cy - 6)
      ..lineTo(cx, cy - 32)
      ..lineTo(cx + 29, cy - 6)
      ..close();
    final roofGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: const [Color(0xFFF59E0B), Color(0xFFD97706), Color(0xFF78350F)],
    );
    canvas.drawPath(roof, Paint()..shader = roofGradient.createShader(roof.getBounds()));

    // Roof Straw Lines
    final strawPaint = Paint()
      ..color = const Color(0xFFFEF08A).withValues(alpha: 0.5)
      ..strokeWidth = 1.5;
    for (double i = -20; i <= 20; i += 8) {
      canvas.drawLine(Offset(cx + i * 0.4, cy - 26), Offset(cx + i, cy - 7), strawPaint);
    }

    // Stone Chimney with 3D Shading
    final chimneyRect = Rect.fromLTWH(cx + 12, cy - 28, 9, 16);
    canvas.drawRect(chimneyRect, Paint()..color = const Color(0xFF475569));
    canvas.drawRect(Rect.fromLTWH(cx + 11, cy - 30, 11, 4), Paint()..color = const Color(0xFF334155));

    // Animated Rising Chimney Smoke Puffs
    for (int i = 0; i < 4; i++) {
      final progress = (animValue + (i * 0.25)) % 1.0;
      final sy = (cy - 32) - (progress * 28);
      final sx = (cx + 16) + (math.sin(progress * math.pi * 2) * 5);
      final r = 3.5 + (progress * 6.5);
      final opacity = (1.0 - progress).clamp(0.0, 0.7);

      canvas.drawCircle(
        Offset(sx, sy),
        r,
        Paint()..color = Colors.white.withValues(alpha: opacity),
      );
    }

    // Flickering Campfire Ring beside hut
    final fireX = cx + 34;
    final fireY = cy + 18;
    for (int i = 0; i < 6; i++) {
      final angle = i * (math.pi / 3);
      final dx = fireX + math.cos(angle) * 7;
      final dy = fireY + math.sin(angle) * 5;
      canvas.drawCircle(Offset(dx, dy), 2.5, Paint()..color = const Color(0xFF475569));
    }
    // Animated Flame
    final flameHeight = 6.0 + (math.sin(animValue * math.pi * 6) * 2.0);
    canvas.drawCircle(Offset(fireX, fireY - 2), flameHeight, Paint()..color = const Color(0xFFEF4444));
    canvas.drawCircle(Offset(fireX, fireY - 3), flameHeight * 0.65, Paint()..color = const Color(0xFFFACC15));
    canvas.drawCircle(Offset(fireX, fireY - 4), flameHeight * 0.35, Paint()..color = Colors.white);
  }

  // --- 2. PREMIUM 3D STONE WINDMILL ---
  void _drawStoneWindmill(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Ground Shadow
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 26), width: 60, height: 18),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Stone Tower Base with 3D Cylindrical Shading
    final towerPath = Path()
      ..moveTo(cx - 20, cy + 24)
      ..lineTo(cx - 14, cy - 20)
      ..lineTo(cx + 14, cy - 20)
      ..lineTo(cx + 20, cy + 24)
      ..close();
    final towerGradient = LinearGradient(
      colors: const [Color(0xFFE2E8F0), Color(0xFFCBD5E1), Color(0xFF64748B)],
    );
    canvas.drawPath(towerPath, Paint()..shader = towerGradient.createShader(towerPath.getBounds()));

    // Stone Masonry Horizontal Lines
    final stoneLinePaint = Paint()
      ..color = const Color(0xFF475569).withValues(alpha: 0.35)
      ..strokeWidth = 1.5;
    for (double y = -10; y <= 20; y += 8) {
      final t = (y + 20) / 44;
      final halfW = 14 + t * 6;
      canvas.drawLine(Offset(cx - halfW, cy + y), Offset(cx + halfW, cy + y), stoneLinePaint);
    }

    // Red Conical Roof Dome with 3D Shading
    final domeRect = Rect.fromCircle(center: Offset(cx, cy - 20), radius: 15);
    final domeGradient = RadialGradient(
      center: const Alignment(-0.3, -0.5),
      colors: const [Color(0xFFEF4444), Color(0xFFDC2626), Color(0xFF7F1D1D)],
    );
    canvas.drawArc(
      domeRect,
      math.pi,
      math.pi,
      true,
      Paint()..shader = domeGradient.createShader(domeRect),
    );

    // Rotating Windmill Sails Axis
    final axisCenter = Offset(cx, cy - 20);
    final rotationAngle = animValue * 2 * math.pi;

    canvas.save();
    canvas.translate(axisCenter.dx, axisCenter.dy);
    canvas.rotate(rotationAngle);

    final bladePaint = Paint()
      ..color = const Color(0xFF5C3A16)
      ..strokeWidth = 3.5;
    final sailGradient = LinearGradient(
      colors: const [Color(0xFFFFFBEB), Color(0xFFFEF3C7), Color(0xFFFDE68A)],
    );

    for (int i = 0; i < 4; i++) {
      final angle = i * (math.pi / 2);
      canvas.save();
      canvas.rotate(angle);
      canvas.drawLine(Offset.zero, const Offset(0, -30), bladePaint);
      final sailRect = const Rect.fromLTWH(2, -28, 9, 20);
      canvas.drawRRect(
        RRect.fromRectAndRadius(sailRect, const Radius.circular(2)),
        Paint()..shader = sailGradient.createShader(sailRect),
      );
      // Sail Cloth Cross Grid Lines
      final gridPaint = Paint()
        ..color = const Color(0xFFD97706).withValues(alpha: 0.4)
        ..strokeWidth = 1;
      canvas.drawLine(const Offset(2, -18), const Offset(11, -18), gridPaint);
      canvas.restore();
    }
    // Brass Center Hub
    canvas.drawCircle(Offset.zero, 5, Paint()..color = const Color(0xFFFACC15));
    canvas.drawCircle(Offset.zero, 3, Paint()..color = const Color(0xFF78350F));
    canvas.restore();

    // Arch Doorway with Wood Texture
    final doorRect = Rect.fromLTWH(cx - 6, cy + 6, 12, 18);
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        doorRect,
        topLeft: const Radius.circular(6),
        topRight: const Radius.circular(6),
      ),
      Paint()..color = const Color(0xFF3B1705),
    );
  }

  // --- 3. PREMIUM 3D VILLAGE MARKET STALL ---
  void _drawVillageMarket(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Ground Shadow
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 24), width: 66, height: 18),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Wooden Stall Counter
    final counterRect = Rect.fromLTWH(cx - 24, cy + 2, 48, 22);
    final woodGradient = LinearGradient(
      colors: const [Color(0xFFB45309), Color(0xFF78350F), Color(0xFF451A03)],
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(counterRect, const Radius.circular(4)),
      Paint()..shader = woodGradient.createShader(counterRect),
    );

    // 3D Striped Awning Roof Canopy
    final awningPath = Path()
      ..moveTo(cx - 28, cy - 6)
      ..lineTo(cx + 28, cy - 6)
      ..lineTo(cx + 25, cy - 22)
      ..lineTo(cx - 25, cy - 22)
      ..close();
    canvas.drawPath(awningPath, Paint()..color = const Color(0xFFDC2626));

    // White Canopy Stripes
    for (int i = -22; i <= 22; i += 11) {
      canvas.drawRect(
        Rect.fromLTWH(cx + i, cy - 22, 5.5, 16),
        Paint()..color = const Color(0xFFF8FAFC),
      );
    }
    // Awning Shadow
    canvas.drawPath(
      awningPath,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Wooden Support Posts
    final postPaint = Paint()
      ..color = const Color(0xFF451A03)
      ..strokeWidth = 3.5;
    canvas.drawLine(Offset(cx - 24, cy - 6), Offset(cx - 24, cy + 2), postPaint);
    canvas.drawLine(Offset(cx + 24, cy - 6), Offset(cx + 24, cy + 2), postPaint);

    // Fruit & Vegetable Wooden Crates
    // Red Apples Crate
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(cx - 18, cy - 2, 12, 9), const Radius.circular(2)),
      Paint()..color = const Color(0xFF92400E),
    );
    canvas.drawCircle(Offset(cx - 15, cy - 4), 3, Paint()..color = const Color(0xFFEF4444));
    canvas.drawCircle(Offset(cx - 10, cy - 4), 3, Paint()..color = const Color(0xFFDC2626));

    // Green Apples Crate
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(cx + 6, cy - 2, 12, 9), const Radius.circular(2)),
      Paint()..color = const Color(0xFF92400E),
    );
    canvas.drawCircle(Offset(cx + 9, cy - 4), 3, Paint()..color = const Color(0xFF22C55E));
    canvas.drawCircle(Offset(cx + 14, cy - 4), 3, Paint()..color = const Color(0xFF16A34A));

    // Hanging Lantern
    final lanternX = cx - 20;
    final lanternY = cy - 2;
    canvas.drawLine(Offset(lanternX, cy - 6), Offset(lanternX, lanternY), Paint()..color = Colors.black..strokeWidth = 1.5);
    canvas.drawCircle(Offset(lanternX, lanternY + 3), 4, Paint()..color = const Color(0xFFFACC15));
    canvas.drawCircle(
      Offset(lanternX, lanternY + 3),
      8,
      Paint()
        ..color = const Color(0xFFFACC15).withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
  }

  // --- 4. EXTREMELY RICH 3D ROYAL CASTLE FORTRESS ---
  void _drawRoyalCastle(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2 + 4;

    // Ground Drop Shadow
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 26), width: 76, height: 22),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    // Stone Texture Shader Gradients
    final mainWallRect = Rect.fromLTWH(cx - 26, cy - 12, 52, 36);
    final stoneWallGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: const [Color(0xFF64748B), Color(0xFF475569), Color(0xFF1E293B)],
    );

    final leftTowerRect = Rect.fromLTWH(cx - 32, cy - 32, 16, 56);
    final rightTowerRect = Rect.fromLTWH(cx + 16, cy - 32, 16, 56);

    final towerGradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: const [Color(0xFF94A3B8), Color(0xFF64748B), Color(0xFF334155)],
    );

    // Draw Main Wall
    canvas.drawRRect(
      RRect.fromRectAndRadius(mainWallRect, const Radius.circular(3)),
      Paint()..shader = stoneWallGradient.createShader(mainWallRect),
    );

    // Draw Towers
    canvas.drawRRect(
      RRect.fromRectAndRadius(leftTowerRect, const Radius.circular(4)),
      Paint()..shader = towerGradient.createShader(leftTowerRect),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rightTowerRect, const Radius.circular(4)),
      Paint()..shader = towerGradient.createShader(rightTowerRect),
    );

    // Embossed Stone Brick Grid Texture Lines
    final brickPaint = Paint()
      ..color = const Color(0xFF0F172A).withValues(alpha: 0.4)
      ..strokeWidth = 1.2;

    for (double y = -24; y <= 20; y += 6) {
      // Left Tower Bricks
      canvas.drawLine(Offset(cx - 31, cy + y), Offset(cx - 17, cy + y), brickPaint);
      // Right Tower Bricks
      canvas.drawLine(Offset(cx + 17, cy + y), Offset(cx + 31, cy + y), brickPaint);
    }
    for (double y = -8; y <= 20; y += 6) {
      // Main Wall Bricks
      canvas.drawLine(Offset(cx - 25, cy + y), Offset(cx + 25, cy + y), brickPaint);
    }

    // Battlements / Crenellations atop main wall
    final battlementPaint = Paint()..color = const Color(0xFF334155);
    for (int i = -24; i <= 20; i += 8) {
      canvas.drawRect(Rect.fromLTWH(cx + i, cy - 18, 5, 6), battlementPaint);
    }

    // 3D Conical Royal Blue Spire Roofs
    final spireGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: const [Color(0xFF60A5FA), Color(0xFF2563EB), Color(0xFF1E3A8A)],
    );

    // Left Spire
    final spire1 = Path()
      ..moveTo(cx - 34, cy - 32)
      ..lineTo(cx - 24, cy - 54)
      ..lineTo(cx - 14, cy - 32)
      ..close();
    canvas.drawPath(spire1, Paint()..shader = spireGradient.createShader(spire1.getBounds()));

    // Right Spire
    final spire2 = Path()
      ..moveTo(cx + 14, cy - 32)
      ..lineTo(cx + 24, cy - 54)
      ..lineTo(cx + 34, cy - 32)
      ..close();
    canvas.drawPath(spire2, Paint()..shader = spireGradient.createShader(spire2.getBounds()));

    // Gold Finial Orbs atop spires
    canvas.drawCircle(Offset(cx - 24, cy - 54), 3, Paint()..color = const Color(0xFFFACC15));
    canvas.drawCircle(Offset(cx + 24, cy - 54), 3, Paint()..color = const Color(0xFFFACC15));

    // Waving Kingdom Banners (Animated Waving Effect)
    final waveOffset = math.sin(animValue * 2 * math.pi) * 2.0;

    // Left Flag Pole & Banner
    canvas.drawLine(Offset(cx - 24, cy - 54), Offset(cx - 24, cy - 66), Paint()..color = const Color(0xFFE2E8F0)..strokeWidth = 2);
    final flag1 = Path()
      ..moveTo(cx - 24, cy - 66)
      ..lineTo(cx - 10 + waveOffset, cy - 63)
      ..lineTo(cx - 24, cy - 58)
      ..close();
    canvas.drawPath(flag1, Paint()..color = const Color(0xFFF59E0B));

    // Right Flag Pole & Banner
    canvas.drawLine(Offset(cx + 24, cy - 54), Offset(cx + 24, cy - 66), Paint()..color = const Color(0xFFE2E8F0)..strokeWidth = 2);
    final flag2 = Path()
      ..moveTo(cx + 24, cy - 66)
      ..lineTo(cx + 38 + waveOffset, cy - 63)
      ..lineTo(cx + 24, cy - 58)
      ..close();
    canvas.drawPath(flag2, Paint()..color = const Color(0xFFF59E0B));

    // Glowing Arched Stained Glass Windows on Towers
    final windowPaint = Paint()..color = const Color(0xFFFDE047);
    final windowFrame = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // Left Tower Window
    final winRect1 = Rect.fromLTWH(cx - 27, cy - 20, 6, 10);
    final winPath1 = Path()..addRRect(RRect.fromRectAndCorners(winRect1, topLeft: const Radius.circular(3), topRight: const Radius.circular(3)));
    canvas.drawPath(winPath1, windowPaint);
    canvas.drawPath(winPath1, windowFrame);

    // Right Tower Window
    final winRect2 = Rect.fromLTWH(cx + 21, cy - 20, 6, 10);
    final winPath2 = Path()..addRRect(RRect.fromRectAndCorners(winRect2, topLeft: const Radius.circular(3), topRight: const Radius.circular(3)));
    canvas.drawPath(winPath2, windowPaint);
    canvas.drawPath(winPath2, windowFrame);

    // Heavy Oak Portcullis Gate with Iron Grate & Arch Shading
    final gateRect = Rect.fromLTWH(cx - 10, cy + 2, 20, 22);
    final gatePath = Path()
      ..addRRect(RRect.fromRectAndCorners(
        gateRect,
        topLeft: const Radius.circular(10),
        topRight: const Radius.circular(10),
      ));
    canvas.drawPath(gatePath, Paint()..color = const Color(0xFF0F172A));

    // Iron Grate Bars inside Portcullis
    final ironPaint = Paint()
      ..color = const Color(0xFFD97706)
      ..strokeWidth = 1.8;
    canvas.drawLine(Offset(cx - 5, cy + 4), Offset(cx - 5, cy + 24), ironPaint);
    canvas.drawLine(Offset(cx, cy + 2), Offset(cx, cy + 24), ironPaint);
    canvas.drawLine(Offset(cx + 5, cy + 4), Offset(cx + 5, cy + 24), ironPaint);
    canvas.drawLine(Offset(cx - 9, cy + 12), Offset(cx + 9, cy + 12), ironPaint);

    // Torches beside gate with light glow
    canvas.drawCircle(Offset(cx - 14, cy + 8), 3, Paint()..color = const Color(0xFFEF4444));
    canvas.drawCircle(
      Offset(cx - 14, cy + 8),
      7,
      Paint()
        ..color = const Color(0xFFFACC15).withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    canvas.drawCircle(Offset(cx + 14, cy + 8), 3, Paint()..color = const Color(0xFFEF4444));
    canvas.drawCircle(
      Offset(cx + 14, cy + 8),
      7,
      Paint()
        ..color = const Color(0xFFFACC15).withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
  }

  // --- 5. PREMIUM 3D VICTORY MONUMENT ---
  void _drawVictoryMonument(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Glowing Golden Divine Aura
    final auraRadius = 34.0 + (math.sin(animValue * math.pi * 4) * 3.0);
    canvas.drawCircle(
      Offset(cx, cy),
      auraRadius,
      Paint()
        ..color = const Color(0xFFFDE047).withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // Marble Arch Base Ground Shadow
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 24), width: 64, height: 18),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Marble Pillars with Shading
    final pillarGradient = LinearGradient(
      colors: const [Color(0xFFFFFFFF), Color(0xFFFEF3C7), Color(0xFFFDE68A)],
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(cx - 22, cy - 18, 9, 38), const Radius.circular(2)),
      Paint()..shader = pillarGradient.createShader(Rect.fromLTWH(cx - 22, cy - 18, 9, 38)),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(cx + 13, cy - 18, 9, 38), const Radius.circular(2)),
      Paint()..shader = pillarGradient.createShader(Rect.fromLTWH(cx + 13, cy - 18, 9, 38)),
    );

    // Marble Arch Top Arc
    final archRect = Rect.fromLTWH(cx - 22, cy - 32, 44, 26);
    canvas.drawArc(
      archRect,
      math.pi,
      math.pi,
      true,
      Paint()..shader = pillarGradient.createShader(archRect),
    );

    // Animated Floating Golden Trophy Crown
    final floatY = cy - 6 + (math.sin(animValue * math.pi * 2) * 3.0);
    canvas.drawCircle(Offset(cx, floatY), 11, Paint()..color = const Color(0xFFFACC15));
    canvas.drawCircle(Offset(cx, floatY), 8, Paint()..color = const Color(0xFFF59E0B));
    canvas.drawCircle(Offset(cx, floatY - 2), 4, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant BuildingPainter oldDelegate) =>
      oldDelegate.stage != stage || oldDelegate.animValue != animValue;
}
