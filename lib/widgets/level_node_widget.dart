import 'package:flutter/material.dart';
import '../models/level_model.dart';
import '../theme/colors.dart';
import 'avatar_widget.dart';

class LevelNodeWidget extends StatefulWidget {
  final LevelModel level;
  final bool isUnlocked;
  final bool isCompleted;
  final bool isCurrent;
  final int earnedStars;
  final VoidCallback onTap;
  final String playerAvatarId;
  final String playerHatId;

  const LevelNodeWidget({
    super.key,
    required this.level,
    required this.isUnlocked,
    required this.isCompleted,
    required this.isCurrent,
    required this.earnedStars,
    required this.onTap,
    this.playerAvatarId = 'hero_wizard',
    this.playerHatId = 'hat_wizard_starter',
  });

  @override
  State<LevelNodeWidget> createState() => _LevelNodeWidgetState();
}

class _LevelNodeWidgetState extends State<LevelNodeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Vibrant World Map Theme Gradients & 3D Bevel Borders
    final Gradient jellyGradient = widget.isCurrent
        ? const LinearGradient(
            colors: [Color(0xFF4ADE80), Color(0xFF22C55E), Color(0xFF15803D)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          )
        : widget.isCompleted
            ? const LinearGradient(
                colors: [Color(0xFFFDE047), Color(0xFFF59E0B), Color(0xFFB45309)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              )
            : widget.isUnlocked
                ? const LinearGradient(
                    colors: [Color(0xFF38BDF8), Color(0xFF0284C7), Color(0xFF0369A1)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  )
                : const LinearGradient(
                    colors: [Color(0xFF64748B), Color(0xFF475569), Color(0xFF1E293B)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  );

    final Color bevelBorderColor = widget.isCurrent
        ? const Color(0xFFF59E0B)
        : widget.isCompleted
            ? const Color(0xFF92400E)
            : widget.isUnlocked
                ? const Color(0xFF075985)
                : const Color(0xFF0F172A);

    return GestureDetector(
      onTap: widget.isUnlocked ? widget.onTap : null,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Full-Body Player Wizard Character standing directly ON THE ROPE PATH!
          if (widget.isCurrent)
            Positioned(
              top: -68,
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  final bobY = (_pulseAnimation.value - 1.0) * 6;
                  return Transform.translate(
                    offset: Offset(0, -bobY),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Hero Badge Pill Above Hat
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFFDF0), Color(0xFFFEF08A)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Text(
                            'YOU HERE! 🚀',
                            style: TextStyle(
                              fontFamily: 'Fredoka',
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF78350F),
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),

                        // Full-Body Wizard Character Asset or Avatar Fallback
                        if (widget.playerAvatarId == 'hero_wizard')
                          Image.asset(
                            'assets/images/wizard_character.png',
                            height: 72,
                            fit: BoxFit.contain,
                          )
                        else
                          AvatarWidget(
                            avatarId: widget.playerAvatarId,
                            equippedHatId: widget.playerHatId,
                            size: 44,
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),

          // Glowing Aura for Active Node
          if (widget.isCurrent)
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 86,
                    height: 86,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                    ),
                  ),
                );
              },
            ),

          // Main GLOSSY 3D JELLY CANDY BUTTON
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: jellyGradient,
              border: Border.all(
                color: bevelBorderColor,
                width: 4.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: bevelBorderColor.withValues(alpha: 0.5),
                  offset: const Offset(0, 7),
                  blurRadius: 4,
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.5),
                  offset: const Offset(0, -2),
                  blurRadius: 2,
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                // 1. TOP-LEFT GLASSY CRESCENT HIGHLIGHT (Candy Crush Gloss Specular Reflection)
                Positioned(
                  top: 3,
                  left: 10,
                  right: 10,
                  child: Container(
                    height: 26,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(35),
                        bottom: Radius.circular(15),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(alpha: 0.7),
                          Colors.white.withValues(alpha: 0.05),
                        ],
                      ),
                    ),
                  ),
                ),

                // 2. CENTER CONTENT (BOLD 3D LEVEL NUMBER OR TRANSLUCENT LOCK)
                Center(
                  child: widget.isUnlocked
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${widget.level.levelNumber}',
                              style: const TextStyle(
                                fontFamily: 'Fredoka',
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.black45,
                                    offset: Offset(1.5, 2.5),
                                    blurRadius: 3,
                                  ),
                                ],
                              ),
                            ),
                            if (widget.isCurrent)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFFFFDF0), Color(0xFFFEF08A)],
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black38,
                                      blurRadius: 3,
                                      offset: Offset(0, 1.5),
                                    ),
                                  ],
                                ),
                                child: const Text(
                                  'PLAY',
                                  style: TextStyle(
                                    fontFamily: 'Fredoka',
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF78350F),
                                  ),
                                ),
                              ),
                          ],
                        )
                      : Stack(
                          alignment: Alignment.center,
                          children: [
                            Text(
                              '${widget.level.levelNumber}',
                              style: TextStyle(
                                fontFamily: 'Fredoka',
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white.withValues(alpha: 0.4),
                              ),
                            ),
                            Icon(
                              Icons.lock_rounded,
                              color: Colors.white.withValues(alpha: 0.85),
                              size: 22,
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),

          // Star Badges under completed nodes
          if (widget.isCompleted || widget.earnedStars > 0)
            Positioned(
              bottom: -12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: GameColors.surfaceWarm,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: GameColors.sunnyYellow, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: GameColors.navyText.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (index) {
                    final hasStar = index < widget.earnedStars;
                    return Icon(
                      hasStar ? Icons.star_rounded : Icons.star_border_rounded,
                      size: 15,
                      color: hasStar
                          ? GameColors.coinGold
                          : Colors.grey.shade400,
                    );
                  }),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
