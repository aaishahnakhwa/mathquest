import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/game_provider.dart';
import '../theme/colors.dart';
import '../widgets/game_button.dart';
import '../widgets/reward_chest_opening_animation.dart';
import 'foundation_builder_screen.dart';
import 'gameplay_screen.dart';

class LevelCompleteScreen extends StatelessWidget {
  const LevelCompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, provider, child) {
        final level = provider.activeLevel;
        final player = provider.player;
        final didPass = provider.didPassLevel;
        final currentWorld = level == null
            ? null
            : provider.worlds.firstWhere(
                (world) => world.id == level.worldId,
                orElse: () => provider.worlds.first,
              );
        final currentIndex = level == null || currentWorld == null
            ? -1
            : currentWorld.levels.indexWhere(
                (candidate) => candidate.id == level.id,
              );
        final nextLevel =
            currentWorld != null &&
                currentIndex >= 0 &&
                currentIndex + 1 < currentWorld.levels.length
            ? currentWorld.levels[currentIndex + 1]
            : null;
        final canStartNext =
            didPass && nextLevel != null && provider.isLevelUnlocked(nextLevel);
        final canBuild =
            level != null &&
            didPass &&
            !provider.isTestMode &&
            provider.supportsLevelBuilding(level) &&
            !provider.isLevelHouseComplete(level);
        if (canBuild) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;
            unawaited(
              FoundationBuilderScreen.precacheAssets(
                context,
                level,
                currentStage: provider.levelHouseStage(level),
              ),
            );
          });
        }

        return PopScope(
          canPop: !provider.isTestMode,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop || !provider.isTestMode) return;
            provider.endTestSession();
            Navigator.pop(context);
          },
          child: Scaffold(
            backgroundColor: GameColors.background,
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 10),

                    if (provider.isTestMode)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0E7FF),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFF6366F1)),
                        ),
                        child: const Text(
                          'TEST MODE · Results and rewards were not saved.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Fredoka',
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3730A3),
                          ),
                        ),
                      ),

                    // Victory Header Banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: didPass
                            ? GameColors.greenGradient
                            : const LinearGradient(
                                colors: [Color(0xFFF97316), Color(0xFFDC2626)],
                              ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color:
                                (didPass
                                        ? GameColors.freshGreen
                                        : GameColors.coral)
                                    .withValues(alpha: 0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            didPass ? '⚔️ VICTORY! ⚔️' : '📘 KEEP PRACTICING!',
                            style: const TextStyle(
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

                    if (didPass)
                      RewardChestOpeningAnimation(
                        earnedStars: provider.earnedStars,
                        earnedCoins: provider.earnedCoins,
                        earnedGems: provider.earnedGems,
                        earnedXp: provider.earnedXp,
                      )
                    else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7ED),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFF97316)),
                        ),
                        child: const Text(
                          'Score at least 3 out of 5 correct answers to pass. No rewards or unlocks were added for this attempt.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF9A3412),
                          ),
                        ),
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

                    // Build this level's new home on its own world-map plot.
                    if (canBuild)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ElevatedButton(
                          onPressed: () async {
                            await FoundationBuilderScreen.open(
                              context,
                              level,
                              currentStage: provider.levelHouseStage(level),
                              replace: true,
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
                              const Text(
                                '🛠️ ',
                                style: TextStyle(fontSize: 18),
                              ),
                              const Text(
                                'BUILD NEW BUILDING',
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
                            text: provider.isTestMode ? 'EXIT TEST' : 'MAP 🗺️',
                            backgroundColor: GameColors.surfaceWarm,
                            shadowColor: Colors.grey.shade400,
                            textColor: GameColors.navyText,
                            height: 52,
                            onPressed: () {
                              provider.endTestSession();
                              Navigator.pop(context);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GameButton(
                            text: provider.isTestMode
                                ? 'NEXT TEST →'
                                : !didPass
                                ? 'RETRY LEVEL'
                                : canStartNext
                                ? 'NEXT QUEST →'
                                : 'REPLAY QUEST',
                            backgroundColor: GameColors.sunnyYellow,
                            shadowColor: GameColors.yellowDark,
                            textColor: GameColors.navyText,
                            height: 52,
                            onPressed: () {
                              if (provider.isTestMode) {
                                final testLevels = provider.worlds
                                    .expand((world) => world.levels)
                                    .toList();
                                final testIndex = level == null
                                    ? -1
                                    : testLevels.indexWhere(
                                        (candidate) => candidate.id == level.id,
                                      );
                                if (testIndex >= 0 &&
                                    testIndex + 1 < testLevels.length) {
                                  provider.startTestLevel(
                                    testLevels[testIndex + 1],
                                  );
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const GameplayScreen(),
                                    ),
                                  );
                                } else {
                                  provider.endTestSession();
                                  Navigator.pop(context);
                                }
                                return;
                              }

                              final destination = canStartNext
                                  ? nextLevel
                                  : level;
                              if (destination == null) {
                                Navigator.pop(context);
                                return;
                              }
                              provider.startLevel(destination);
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const GameplayScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
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
