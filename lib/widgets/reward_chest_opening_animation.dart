import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/colors.dart';
import 'gift_box_painter.dart';

class RewardChestOpeningAnimation extends StatefulWidget {
  final int earnedStars;
  final int earnedCoins;
  final int earnedGems;
  final int earnedXp;
  final VoidCallback? onFinished;

  const RewardChestOpeningAnimation({
    super.key,
    required this.earnedStars,
    required this.earnedCoins,
    required this.earnedGems,
    required this.earnedXp,
    this.onFinished,
  });

  @override
  State<RewardChestOpeningAnimation> createState() =>
      _RewardChestOpeningAnimationState();
}

class _RewardChestOpeningAnimationState
    extends State<RewardChestOpeningAnimation>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _openController;
  late AnimationController _confettiController;

  bool _isOpened = false;

  final List<_ConfettiRibbon> _ribbons = List.generate(48, (index) {
    final rng = math.Random(index);
    return _ConfettiRibbon(
      color: [
        const Color(0xFFFACC15),
        const Color(0xFFEC4899),
        const Color(0xFF38BDF8),
        const Color(0xFF22C55E),
        const Color(0xFFA855F7),
      ][index % 5],
      angle: rng.nextDouble() * 2 * math.pi,
      speed: 90 + (rng.nextDouble() * 150),
      width: 5.0 + rng.nextDouble() * 6.0,
      height: 10.0 + rng.nextDouble() * 12.0,
      rotation: rng.nextDouble() * 2 * math.pi,
    );
  });

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _openController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _openController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _openChest() {
    if (_isOpened) return;

    setState(() => _isOpened = true);
    _pulseController.stop();
    _openController.forward();
    _confettiController.forward();

    if (widget.onFinished != null) {
      Future.delayed(const Duration(milliseconds: 1600), widget.onFinished);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: _openChest,
          child: SizedBox(
            height: 280,
            width: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // Confetti Explosion Painter (Vector Confetti Ribbons!)
                if (_isOpened)
                  AnimatedBuilder(
                    animation: _confettiController,
                    builder: (context, child) {
                      return CustomPaint(
                        size: const Size(320, 280),
                        painter: _VectorConfettiPainter(
                          ribbons: _ribbons,
                          progress: _confettiController.value,
                        ),
                      );
                    },
                  ),

                // Pulsing Hand-Painted Treasure Chest (Closed State)
                if (!_isOpened)
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      final scale = 1.0 + (_pulseController.value * 0.06);
                      return Transform.scale(
                        scale: scale,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomPaint(
                              size: const Size(120, 100),
                              painter: GiftBoxPainter(
                                isOpen: false,
                                openProgress: 0.0,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: GameColors.freshGreen,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: GameColors.freshGreenDark.withValues(
                                      alpha: 0.4,
                                    ),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.touch_app_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'TAP TO OPEN TREASURE CHEST!',
                                    style: TextStyle(
                                      fontFamily: 'Fredoka',
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                // Opened Treasure Chest with Vector Rewards Bursting Out!
                if (_isOpened)
                  AnimatedBuilder(
                    animation: _openController,
                    builder: (context, child) {
                      final popVal = CurvedAnimation(
                        parent: _openController,
                        curve: Curves.elasticOut,
                      ).value;

                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          // Vector Hand-Painted Open Chest Graphic
                          Positioned(
                            bottom: 25,
                            child: CustomPaint(
                              size: const Size(130, 110),
                              painter: GiftBoxPainter(
                                isOpen: true,
                                openProgress: _openController.value,
                              ),
                            ),
                          ),

                          // Floating Rewards Burst (+Coins, +Gems, Vector 3D Stars)
                          Positioned(
                            top: 45 - (popVal * 25),
                            child: Transform.scale(
                              scale: popVal,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Vector 3D Stars Row
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: List.generate(3, (index) {
                                      final hasStar =
                                          index < widget.earnedStars;
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4.0,
                                        ),
                                        child: VectorStarWidget(
                                          size: 38,
                                          isFilled: hasStar,
                                        ),
                                      );
                                    }),
                                  ),
                                  const SizedBox(height: 10),

                                  // Vector Coins & Gems Reward Pills
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: GameColors.sunnyYellow,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Colors.black26,
                                              blurRadius: 6,
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            const VectorCoinIcon(size: 18),
                                            const SizedBox(width: 6),
                                            Text(
                                              '+${widget.earnedCoins}',
                                              style: const TextStyle(
                                                fontFamily: 'Fredoka',
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: GameColors.navyText,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: GameColors.gemPurple,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Colors.black26,
                                              blurRadius: 6,
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            const VectorGemIcon(size: 18),
                                            const SizedBox(width: 6),
                                            Text(
                                              '+${widget.earnedGems}',
                                              style: const TextStyle(
                                                fontFamily: 'Fredoka',
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ConfettiRibbon {
  final Color color;
  final double angle;
  final double speed;
  final double width;
  final double height;
  final double rotation;

  _ConfettiRibbon({
    required this.color,
    required this.angle,
    required this.speed,
    required this.width,
    required this.height,
    required this.rotation,
  });
}

class _VectorConfettiPainter extends CustomPainter {
  final List<_ConfettiRibbon> ribbons;
  final double progress;

  _VectorConfettiPainter({required this.ribbons, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (final r in ribbons) {
      final dist = r.speed * progress;
      final dx = center.dx + math.cos(r.angle) * dist;
      final dy =
          center.dy + math.sin(r.angle) * dist + (progress * progress * 100);
      final opacity = (1.0 - progress).clamp(0.0, 1.0);

      canvas.save();
      canvas.translate(dx, dy);
      canvas.rotate(r.rotation + (progress * math.pi * 2));

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(-r.width / 2, -r.height / 2, r.width, r.height),
        const Radius.circular(2),
      );

      canvas.drawRRect(
        rect,
        Paint()..color = r.color.withValues(alpha: opacity),
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _VectorConfettiPainter oldDelegate) => true;
}
