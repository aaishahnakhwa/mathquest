import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/building_model.dart';
import '../providers/game_provider.dart';
import '../theme/colors.dart';

class HutUpgradeDialog extends StatelessWidget {
  final BuildingModel building;

  const HutUpgradeDialog({super.key, required this.building});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, provider, child) {
        final player = provider.player;
        final currentBuilding = provider.activeBuildings.firstWhere(
          (b) => b.id == building.id,
          orElse: () => building,
        );

        final isMax = currentBuilding.isMaxStage;
        final coinCost = currentBuilding.nextStageCoinCost;
        final woodCost = currentBuilding.nextStageWoodCost;

        final hasEnoughCoins = player.coins >= coinCost;
        final hasEnoughWood = player.woodLogs >= woodCost;
        final canAfford = hasEnoughCoins && hasEnoughWood;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 10,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: GameColors.surfaceWarm,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: GameColors.cardBorder, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header Icon & Title
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: GameColors.skyBlue.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: GameColors.skyBlue.withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        currentBuilding.iconEmoji,
                        style: const TextStyle(fontSize: 36),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentBuilding.name,
                            style: const TextStyle(
                              fontFamily: 'Fredoka',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: GameColors.navyText,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isMax
                                  ? GameColors.freshGreen
                                  : GameColors.streakOrange,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              currentBuilding.currentStageTitle,
                              style: const TextStyle(
                                fontFamily: 'Fredoka',
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: GameColors.navyTextMuted,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                Text(
                  currentBuilding.description,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 14,
                    color: GameColors.navyTextSecondary,
                  ),
                ),

                const SizedBox(height: 12),
                // Perk Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: GameColors.sunnyYellow.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: GameColors.yellowDark.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Text('✨ ', style: TextStyle(fontSize: 16)),
                      Expanded(
                        child: Text(
                          'Perk: ${currentBuilding.perkDescription}',
                          style: const TextStyle(
                            fontFamily: 'Fredoka',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: GameColors.yellowDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                if (!isMax) ...[
                  // Cost Requirements
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Upgrade Cost:',
                      style: TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: GameColors.navyText,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Coins Pill
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: hasEnoughCoins
                                ? GameColors.freshGreen.withValues(alpha: 0.12)
                                : Colors.red.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: hasEnoughCoins
                                  ? GameColors.freshGreen
                                  : Colors.redAccent,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('💰', style: TextStyle(fontSize: 16)),
                              const SizedBox(width: 6),
                              Text(
                                '$coinCost / ${player.coins}',
                                style: TextStyle(
                                  fontFamily: 'Fredoka',
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: hasEnoughCoins
                                      ? GameColors.freshGreen
                                      : Colors.redAccent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Wood Logs Pill
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: hasEnoughWood
                                ? GameColors.freshGreen.withValues(alpha: 0.12)
                                : Colors.red.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: hasEnoughWood
                                  ? GameColors.freshGreen
                                  : Colors.redAccent,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/wood_log.png',
                                height: 20,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '$woodCost / ${player.woodLogs}',
                                style: TextStyle(
                                  fontFamily: 'Fredoka',
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: hasEnoughWood
                                      ? GameColors.freshGreen
                                      : Colors.redAccent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Upgrade Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: canAfford
                          ? () {
                              final success = provider.upgradeBuilding(
                                currentBuilding.id,
                              );
                              if (success) {
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '🎉 Upgraded ${currentBuilding.name} to ${currentBuilding.nextStageTitle}!',
                                      style: const TextStyle(
                                        fontFamily: 'Fredoka',
                                      ),
                                    ),
                                    backgroundColor: GameColors.freshGreen,
                                  ),
                                );
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GameColors.turquoise,
                        disabledBackgroundColor: Colors.grey.shade400,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: canAfford ? 4 : 0,
                      ),
                      child: Text(
                        currentBuilding.currentStage == 0
                            ? '🛠️ LAY FOUNDATION'
                            : '🪵 UPGRADE HUT',
                        style: const TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: GameColors.freshGreen.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('🎉 ', style: TextStyle(fontSize: 18)),
                        Text(
                          'Max Stage Achieved!',
                          style: TextStyle(
                            fontFamily: 'Fredoka',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: GameColors.freshGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
