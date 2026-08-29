import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import 'era_builder_painter.dart';

/// PERSISTENT ERA-AUTHENTIC ANIMATED BUILDER WORKER
class PersistentBuilderManWidget extends StatelessWidget {
  final int activeStage;
  final double animValue;
  final VoidCallback? onTap;

  const PersistentBuilderManWidget({
    super.key,
    required this.activeStage,
    required this.animValue,
    this.onTap,
  });

  String get _workerTitle {
    switch (activeStage) {
      case 1:
        return 'Stone Age Caveman 🪨';
      case 2:
        return 'Timber Carpenter 🪵';
      case 3:
        return 'Iron Age Blacksmith ⚒️';
      case 4:
        return 'Castle Stonemason 🏰';
      case 5:
        return 'Imperial Architect 👑';
      default:
        return 'Master Builder 🔨';
    }
  }

  String get _workerStatusText {
    switch (activeStage) {
      case 1:
        return 'Building Stone Age Hut! 🛖';
      case 2:
        return 'Upgrading Timber Windmill! 🌾';
      case 3:
        return 'Forging Iron Age Smithy! ⚒️';
      case 4:
        return 'Building Royal Castle! 🏰';
      case 5:
        return 'Building Imperial Citadel! 👑';
      default:
        return 'Master Builder at Work! 🔨';
    }
  }

  String get _miniBadgeText {
    switch (activeStage) {
      case 1:
        return '🪨 Builder';
      case 2:
        return '🪵 Builder';
      case 3:
        return '⚒️ Blacksmith';
      case 4:
        return '🏰 Stonemason';
      case 5:
        return '👑 Architect';
      default:
        return '🔨 Builder';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap!();
        } else {
          _showBuilderDialog(context);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // COMPACT MINI ERA BADGE CHIP (NO OVERLAPPING WIDE SPEECH BUBBLE!)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: GameColors.navyText.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: GameColors.sunnyYellow, width: 1.5),
            ),
            child: Text(
              _miniBadgeText,
              style: const TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 2),

          // REAL HIGH-RES 2D CUSTOM PAINTED ERA BUILDER SPRITE
          CustomPaint(
            size: const Size(56, 56),
            painter: EraBuilderPainter(
              stage: activeStage,
              animValue: animValue,
            ),
          ),
        ],
      ),
    );
  }

  void _showBuilderDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: GameColors.surfaceWarm,
        title: Row(
          children: [
            const Text('⚒️ ', style: TextStyle(fontSize: 28)),
            Expanded(
              child: Text(
                _workerTitle,
                style: const TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: GameColors.navyText,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'I am building your civilization! Complete more math quests to evolve from the Stone Age to the Iron Age and Imperial Citadel!',
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                color: GameColors.navyTextSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: GameColors.sunnyYellow.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: GameColors.sunnyYellow, width: 1.5),
              ),
              child: Row(
                children: [
                  const Text('🔨 ', style: TextStyle(fontSize: 20)),
                  Expanded(
                    child: Text(
                      'Active Construction: $_workerStatusText',
                      style: const TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: GameColors.navyText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'KEEP BUILDING! 🔨',
              style: TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: GameColors.skyBlueDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ANIMATED CUTSCENE FOR LEVEL COMPLETE UPGRADES
class BuildingConstructionWidget extends StatefulWidget {
  final int stage;
  final VoidCallback onComplete;

  const BuildingConstructionWidget({
    super.key,
    required this.stage,
    required this.onComplete,
  });

  @override
  State<BuildingConstructionWidget> createState() =>
      _BuildingConstructionWidgetState();
}

class _BuildingConstructionWidgetState extends State<BuildingConstructionWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );

    _controller.forward().then((_) {
      if (mounted) {
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _eraTitle {
    switch (widget.stage) {
      case 1:
        return 'STONE AGE HUT BUILT!';
      case 2:
        return 'TIMBER WINDMILL BUILT!';
      case 3:
        return 'IRON AGE FORGE BUILT!';
      case 4:
        return 'ROYAL CASTLE BUILT!';
      case 5:
        return 'VICTORY CITADEL BUILT!';
      default:
        return 'BUILDING COMPLETE!';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = _controller.value;
        final scaleVal = (progress * 1.3).clamp(0.0, 1.0);
        final opacity = progress > 0.85 ? (1.0 - progress) / 0.15 : 1.0;

        return Opacity(
          opacity: opacity.clamp(0.0, 1.0),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // 1. DUST & SPARK PARTICLES
              CustomPaint(
                size: const Size(130, 130),
                painter: _ConstructionParticlePainter(progress: progress),
              ),

              // 2. SCAFFOLDING FRAME & SCALE EFFECT
              Transform.scale(
                scale: scaleVal,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: GameColors.sunnyYellow,
                      width: 3,
                    ),
                  ),
                ),
              ),

              // 3. REAL 2D CUSTOM PAINTED ERA BUILDER CHARACTER
              Positioned(
                bottom: -10,
                right: -14,
                child: CustomPaint(
                  size: const Size(60, 60),
                  painter: EraBuilderPainter(
                    stage: widget.stage,
                    animValue: progress,
                  ),
                ),
              ),

              // 4. FLOATING ERA BANNER TITLE
              Positioned(
                top: -34,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: GameColors.jellyYellowGradient,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: GameColors.jellyYellowDark, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: GameColors.jellyYellowDark.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    _eraTitle,
                    style: const TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ConstructionParticlePainter extends CustomPainter {
  final double progress;

  _ConstructionParticlePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final rand = math.Random(42);

    // Dust Cloud Puffs
    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi / 4) + (rand.nextDouble() * 0.2);
      final dist = (progress * 45.0) * (0.8 + rand.nextDouble() * 0.4);
      final dx = cx + math.cos(angle) * dist;
      final dy = cy + math.sin(angle) * dist;
      final radius = 6.0 + (progress * 14.0);
      final alpha = (1.0 - progress).clamp(0.0, 0.6);

      canvas.drawCircle(
        Offset(dx, dy),
        radius,
        Paint()..color = Colors.amber.shade200.withValues(alpha: alpha),
      );
    }

    // Spark Particles 🌟
    for (int i = 0; i < 14; i++) {
      final angle = rand.nextDouble() * math.pi * 2;
      final dist = progress * 60.0;
      final dx = cx + math.cos(angle) * dist;
      final dy = cy + math.sin(angle) * dist;
      final alpha = (1.0 - (progress * 0.9)).clamp(0.0, 1.0);

      canvas.drawCircle(
        Offset(dx, dy),
        3.0,
        Paint()..color = Colors.orangeAccent.withValues(alpha: alpha),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ConstructionParticlePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
