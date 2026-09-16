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
  final VoidCallback? onBuildTap;
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
    this.onBuildTap,
    this.playerAvatarId = AvatarWidget.maleWizardId,
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
    final playerCharacterAsset = AvatarWidget.mapCharacterAssetFor(
      widget.playerAvatarId,
    );
    final int buttonIndex = widget.level.levelNumber <= 11
        ? widget.level.levelNumber
        : (((widget.level.levelNumber - 1) % 10) + 1);

    return SizedBox(
      width: 120,
      height: 70,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.centerLeft,
        children: [
          // 1. LEVEL NODE SPRITE & AVATAR
          Positioned(
            left: 0,
            top: 0,
            width: 58,
            height: 50,
            child: GestureDetector(
              onTap: widget.isUnlocked ? widget.onTap : null,
              behavior: HitTestBehavior.opaque,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  // Full-Body Player Wizard Character standing directly above current level node
                  if (widget.isCurrent)
                    Positioned(
                      top: -44,
                      child: AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          final bobY = (_pulseAnimation.value - 1.0) * 4;
                          return Transform.translate(
                            offset: Offset(0, -bobY),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Hero Badge Pill Above Hat
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFFFFDF0),
                                        Color(0xFFFEF08A),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFFF59E0B),
                                      width: 1.2,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 2.5,
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: const Text(
                                    'YOU HERE! 🚀',
                                    style: TextStyle(
                                      fontFamily: 'Fredoka',
                                      fontSize: 7.5,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF78350F),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 1.5),

                                // Full-Body Wizard Character Asset or Avatar Fallback
                                if (playerCharacterAsset != null)
                                  Image.asset(
                                    playerCharacterAsset,
                                    height: 48,
                                    fit: BoxFit.contain,
                                  )
                                else
                                  AvatarWidget(
                                    avatarId: widget.playerAvatarId,
                                    equippedHatId: widget.playerHatId,
                                    size: 34,
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
                            width: 58,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFF59E0B)
                                  .withValues(alpha: 0.35),
                            ),
                          ),
                        );
                      },
                    ),

                  // INDIVIDUAL EXTRACTED LEVEL BUTTON SPRITE (Unlocked 1..5 OR Custom Locked Asset)
                  SizedBox(
                    width: 58,
                    height: 50,
                    child: Image.asset(
                      widget.isUnlocked
                          ? 'assets/images/level_btn_$buttonIndex.png'
                          : 'assets/images/level_btn_locked.png',
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    ),
                  ),

                  // Star Badges under completed nodes
                  if (widget.isCompleted || widget.earnedStars > 0)
                    Positioned(
                      bottom: -12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1.5,
                        ),
                        decoration: BoxDecoration(
                          color: GameColors.surfaceWarm,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: GameColors.sunnyYellow,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: GameColors.navyText.withValues(alpha: 0.2),
                              blurRadius: 3,
                              offset: const Offset(0, 1.5),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(3, (index) {
                            final hasStar = index < widget.earnedStars;
                            return Icon(
                              hasStar
                                  ? Icons.star_rounded
                                  : Icons.star_border_rounded,
                              size: 11,
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
            ),
          ),

          // 2. SIDE UPGRADE / BUILD BUTTON (Compact pill badge)
          if (widget.isCompleted && widget.onBuildTap != null)
            Positioned(
              left: 48,
              top: 24,
              child: GestureDetector(
                onTap: widget.onBuildTap,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white, width: 1.2),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 2.5,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset('assets/images/wood_log.png', height: 9),
                      const SizedBox(width: 2),
                      const Text(
                        'BUILD 🛠️',
                        style: TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 7.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
