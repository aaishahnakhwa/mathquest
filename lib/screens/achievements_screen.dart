import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/game_provider.dart';
import '../models/achievement_model.dart';
import '../theme/colors.dart';
import '../widgets/game_button.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, provider, child) {
        final achievements = provider.achievements;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'COLLECTIBLE BADGES',
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: GameColors.navyText,
                ),
              ),
              const Text(
                'Complete milestones to earn coins & rare gems!',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13,
                  color: GameColors.navyTextSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),

              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: achievements.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final ach = achievements[index];
                  return _buildAchievementCard(context, provider, ach);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAchievementCard(
    BuildContext context,
    GameProvider provider,
    AchievementModel ach,
  ) {
    final progressRatio = (ach.currentProgress / ach.requiredProgress).clamp(
      0.0,
      1.0,
    );
    final isCompleted = ach.isCompleted;
    final isClaimed = ach.isClaimed;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isClaimed ? Colors.white.withValues(alpha: 0.6) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isCompleted && !isClaimed
              ? GameColors.sunnyYellow
              : GameColors.cardBorder,
          width: isCompleted && !isClaimed ? 2.5 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: GameColors.navyText.withValues(alpha: 0.06),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        children: [
          // Badge Icon Circle
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted
                  ? GameColors.sunnyYellow.withValues(alpha: 0.25)
                  : Colors.grey.shade200,
              border: Border.all(
                color: isCompleted
                    ? GameColors.sunnyYellow
                    : Colors.grey.shade300,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(ach.iconEmoji, style: const TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(width: 14),

          // Details & Progress Bar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ach.title,
                  style: const TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: GameColors.navyText,
                  ),
                ),
                Text(
                  ach.description,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    color: GameColors.navyTextSecondary,
                  ),
                ),
                const SizedBox(height: 8),

                // Progress Bar
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Stack(
                          children: [
                            Container(height: 8, color: Colors.grey.shade200),
                            FractionallySizedBox(
                              widthFactor: progressRatio,
                              child: Container(
                                height: 8,
                                color: isCompleted
                                    ? GameColors.freshGreen
                                    : GameColors.skyBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${ach.currentProgress.toInt()}/${ach.requiredProgress.toInt()}',
                      style: const TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: GameColors.navyTextSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Claim Action Button
          if (isClaimed)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'CLAIMED ✅',
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            )
          else
            GameButton(
              text: 'CLAIM',
              backgroundColor: isCompleted
                  ? GameColors.sunnyYellow
                  : GameColors.nodeLocked,
              shadowColor: GameColors.yellowDark,
              textColor: GameColors.navyText,
              height: 38,
              fontSize: 12,
              onPressed: isCompleted
                  ? () => provider.claimAchievementReward(ach.id)
                  : null,
            ),
        ],
      ),
    );
  }
}
