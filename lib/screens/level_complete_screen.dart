import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/game_provider.dart';
import '../theme/colors.dart';
import '../widgets/game_button.dart';
import '../widgets/reward_chest_opening_animation.dart';
import 'foundation_builder_screen.dart';

class LevelCompleteScreen extends StatelessWidget {
  const LevelCompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, provider, child) {
        final level = provider.activeLevel;
        final player = provider.player;

        return Scaffold(
          backgroundColor: GameColors.background,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  // Victory Header Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: GameColors.greenGradient,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: GameColors.freshGreen.withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          '⚔️ VICTORY! ⚔️',
                          style: TextStyle(
                            fontFamily: 'Fredoka',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          level?.title.toUpperCase() ?? 'LEVEL COMPLETE!',
                          style: const TextStyle(
                            fontFamily: 'Fredoka',
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // INTERACTIVE REWARD GIFT BOX WITH CONFETTI & POP-OUT BURST!
                  RewardChestOpeningAnimation(
                    earnedStars: provider.earnedStars,
                    earnedCoins: provider.earnedCoins,
                    earnedGems: provider.earnedGems,
                    earnedXp: provider.earnedXp,
                  ),
                  const SizedBox(height: 10),

                  // STATS BREAKDOWN CARD
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: GameColors.cardBorder,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: GameColors.navyText.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildStatRow(
                          'Correct Answers',
                          '${provider.levelCorrectCount} / ${level?.questions.length ?? 5}',
                        ),
                        const Divider(height: 16),
                        _buildStatRow(
                          'Hints Used',
                          '${provider.hintsUsedInLevel}',
                        ),
                        const Divider(height: 16),
                        _buildStatRow(
                          'XP Gained',
                          '+${provider.earnedXp} XP',
                          valueColor: GameColors.xpBlue,
                        ),
                        const Divider(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Wood Logs Earned',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: GameColors.navyTextSecondary,
                              ),
                            ),
                            Row(
                              children: [
                                Image.asset(
                                  'assets/images/wood_log.png',
                                  height: 20,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '+${provider.earnedWoodLogs}',
                                  style: const TextStyle(
                                    fontFamily: 'Fredoka',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: GameColors.streakOrange,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Divider(height: 16),
                        _buildStatRow(
                          'Overall Accuracy',
                          '${player.accuracyPercentage.toStringAsFixed(0)}%',
                          valueColor: GameColors.freshGreen,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // GO TO HOUSE BUILDER BUTTON (Only if not already built)
                  if (level != null &&
                      level.worldId == 'world_1' &&
                      !provider.isLevelHouseComplete(level))
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  FoundationBuilderScreen(level: level),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: GameColors.skyBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 4,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('🛠️ ', style: TextStyle(fontSize: 18)),
                            const Text(
                              'BUILD / UPGRADE HOUSE',
                              style: TextStyle(
                                fontFamily: 'Fredoka',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Image.asset(
                              'assets/images/wood_log.png',
                              height: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),

                  // BOTTOM NAVIGATION ACTION BUTTONS
                  Row(
                    children: [
                      Expanded(
                        child: GameButton(
                          text: 'MAP 🗺️',
                          backgroundColor: GameColors.surfaceWarm,
                          shadowColor: Colors.grey.shade400,
                          textColor: GameColors.navyText,
                          height: 52,
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GameButton(
                          text: 'NEXT QUEST →',
                          backgroundColor: GameColors.sunnyYellow,
                          shadowColor: GameColors.yellowDark,
                          textColor: GameColors.navyText,
                          height: 52,
                          onPressed: () {
                            Navigator.pop(context);
                            // Auto select next level if available
                            if (level != null) {
                              final world = provider.worlds.firstWhere(
                                (w) => w.id == level.worldId,
                                orElse: () => provider.worlds.first,
                              );
                              final currentIndex = world.levels.indexWhere(
                                (l) => l.id == level.id,
                              );
                              if (currentIndex != -1 &&
                                  currentIndex + 1 < world.levels.length) {
                                final nextLevel =
                                    world.levels[currentIndex + 1];
                                provider.startLevel(nextLevel);
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: GameColors.navyTextSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Fredoka',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: valueColor ?? GameColors.navyText,
          ),
        ),
      ],
    );
  }
}
