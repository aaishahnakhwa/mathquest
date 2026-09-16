import 'package:flutter/material.dart';

import '../models/world_model.dart';
import '../models/player_model.dart';
import '../theme/colors.dart';
import 'game_button.dart';

class WorldPreviewModal extends StatelessWidget {
  final WorldModel world;
  final PlayerModel player;
  final bool isUnlocked;
  final Function(String levelId)? onLevelSelected;

  const WorldPreviewModal({
    super.key,
    required this.world,
    required this.player,
    required this.isUnlocked,
    this.onLevelSelected,
  });

  static void show(
    BuildContext context, {
    required WorldModel world,
    required PlayerModel player,
    required bool isUnlocked,
    Function(String levelId)? onLevelSelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => WorldPreviewModal(
        world: world,
        player: player,
        isUnlocked: isUnlocked,
        onLevelSelected: onLevelSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final starsNeeded = world.reqStarsToUnlock;
    final currentStars = player.totalStars;
    final progressRatio = starsNeeded > 0
        ? (currentStars / starsNeeded).clamp(0.0, 1.0)
        : 1.0;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: GameColors.surfaceWarm,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: GameColors.sunnyYellow, width: 3),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle Pill
          const SizedBox(height: 12),
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 16),

          // Header World Banner
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [world.primaryColor, world.secondaryColor],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: world.primaryColor.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          world.iconEmoji,
                          style: const TextStyle(fontSize: 38),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'WORLD ${world.worldNumber} PREVIEW',
                              style: const TextStyle(
                                fontFamily: 'Fredoka',
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white70,
                                letterSpacing: 1.3,
                              ),
                            ),
                            Text(
                              world.name,
                              style: const TextStyle(
                                fontFamily: 'Fredoka',
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              world.subtitle,
                              style: const TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 13,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isUnlocked
                              ? GameColors.freshGreen
                              : GameColors.coral,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: Text(
                          isUnlocked ? 'UNLOCKED' : 'LOCKED',
                          style: const TextStyle(
                            fontFamily: 'Fredoka',
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    world.description,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 13,
                      color: Colors.white,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Unlock Requirement Bar if locked
          if (!isUnlocked)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: GameColors.cardBorder, width: 2),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            Text('🔒 ', style: TextStyle(fontSize: 16)),
                            Text(
                              'Unlock Requirement',
                              style: TextStyle(
                                fontFamily: 'Fredoka',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: GameColors.navyText,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '$currentStars / $starsNeeded Stars ⭐',
                          style: TextStyle(
                            fontFamily: 'Fredoka',
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: currentStars >= starsNeeded
                                ? GameColors.freshGreen
                                : GameColors.coral,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progressRatio,
                        minHeight: 10,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          currentStars >= starsNeeded
                              ? GameColors.freshGreen
                              : GameColors.sunnyYellow,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 12),

          // Level Breakdown Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'LEVEL BREAKDOWN',
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: GameColors.navyTextSecondary,
                    letterSpacing: 1.1,
                  ),
                ),
                Text(
                  '${world.levels.length} Levels',
                  style: const TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: GameColors.skyBlueDark,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Scrollable Level List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              itemCount: world.levels.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final level = world.levels[index];
                final earnedStars = player.levelStars[level.id] ?? 0;
                final isCompleted = player.completedLevelIds.contains(level.id);

                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isCompleted
                          ? GameColors.freshGreen.withValues(alpha: 0.5)
                          : GameColors.cardBorder,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: GameColors.navyText.withValues(alpha: 0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Level Badge Icon
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? GameColors.freshGreenLight
                              : GameColors.skyBlueLight,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            level.iconEmoji,
                            style: const TextStyle(fontSize: 22),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Level Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Level ${level.levelNumber}: ',
                                  style: const TextStyle(
                                    fontFamily: 'Fredoka',
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: GameColors.skyBlueDark,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    level.title,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontFamily: 'Fredoka',
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: GameColors.navyText,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: GameColors.skyBlueLight,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    level.topic,
                                    style: const TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: GameColors.skyBlueDark,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: GameColors.freshGreenLight,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    level.difficulty,
                                    style: const TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: GameColors.freshGreenDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Stars Earned / Question Count
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: List.generate(3, (sIndex) {
                              final hasStar = sIndex < earnedStars;
                              return Icon(
                                hasStar
                                    ? Icons.star_rounded
                                    : Icons.star_border_rounded,
                                size: 18,
                                color: hasStar
                                    ? GameColors.coinGold
                                    : Colors.grey.shade300,
                              );
                            }),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${level.questions.length} Questions',
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: GameColors.navyTextMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Close / Action Button
          Padding(
            padding: const EdgeInsets.all(20),
            child: GameButton(
              text: 'CLOSE PREVIEW',
              backgroundColor: GameColors.surfaceWarm,
              shadowColor: Colors.grey.shade400,
              textColor: GameColors.navyText,
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
