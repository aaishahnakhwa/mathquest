import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/game_provider.dart';
import '../theme/colors.dart';
import '../widgets/game_button.dart';
import '../widgets/reward_chest_widget.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, provider, child) {
        final player = provider.player;

        return Scaffold(
          backgroundColor: GameColors.background,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Section
                  const Text(
                    'DAILY REWARDS',
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: GameColors.navyText,
                    ),
                  ),
                  const Text(
                    'Claim free coins, gems, and mystery chests!',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 13,
                      color: GameColors.navyTextSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 1. WATCH REWARDED AD CARD (+5 FREE GEMS)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          GameColors.gemPurple.withValues(alpha: 0.9),
                          GameColors.purpleAccent,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: GameColors.gemPurple.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Text('📺', style: TextStyle(fontSize: 28)),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'WATCH AD FOR GEMS',
                                style: TextStyle(
                                  fontFamily: 'Fredoka',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Earn +5 Free Gems 💎 per video!',
                                style: TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 12,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GameButton(
                          text: '+5 GEMS 💎',
                          backgroundColor: GameColors.sunnyYellow,
                          shadowColor: GameColors.yellowDark,
                          textColor: GameColors.navyText,
                          height: 38,
                          fontSize: 11,
                          onPressed: () =>
                              _showRewardedAdModal(context, provider),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 2. STREAK PROGRESS CARD
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  '🔥 ',
                                  style: TextStyle(fontSize: 24),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${player.streakDays} DAY STREAK',
                                      style: const TextStyle(
                                        fontFamily: 'Fredoka',
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: GameColors.streakOrange,
                                      ),
                                    ),
                                    const Text(
                                      'Play daily to keep your multiplier active!',
                                      style: TextStyle(
                                        fontFamily: 'Nunito',
                                        fontSize: 12,
                                        color: GameColors.navyTextMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // 7 Day Streak Bubbles
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(7, (index) {
                            final dayNum = index + 1;
                            final isCompleted = dayNum <= player.streakDays;
                            final isCurrent = dayNum == player.streakDays;

                            return Column(
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isCompleted
                                        ? GameColors.streakOrange
                                        : Colors.grey.shade200,
                                    border: isCurrent
                                        ? Border.all(
                                            color: GameColors.sunnyYellow,
                                            width: 3,
                                          )
                                        : null,
                                  ),
                                  child: Center(
                                    child: isCompleted
                                        ? const Icon(
                                            Icons.check_rounded,
                                            color: Colors.white,
                                            size: 20,
                                          )
                                        : Text(
                                            '$dayNum',
                                            style: const TextStyle(
                                              fontFamily: 'Fredoka',
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey,
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Day $dayNum',
                                  style: const TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: GameColors.navyTextMuted,
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 3. DAILY REWARD CLAIM CARD
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
                    ),
                    child: Column(
                      children: [
                        const Text('🎁', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 8),
                        const Text(
                          'DAILY REWARD',
                          style: TextStyle(
                            fontFamily: 'Fredoka',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: GameColors.navyText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Log in every 24 hours for bonus coins!',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 13,
                            color: GameColors.navyTextMuted,
                          ),
                        ),
                        const SizedBox(height: 16),
                        GameButton(
                          text: !provider.canClaimDailyReward
                              ? 'CLAIMED TODAY ✓'
                              : 'CLAIM 50 COINS 💰',
                          backgroundColor: !provider.canClaimDailyReward
                              ? Colors.grey.shade400
                              : GameColors.freshGreen,
                          shadowColor: !provider.canClaimDailyReward
                              ? Colors.grey.shade600
                              : GameColors.freshGreenDark,
                          textColor: Colors.white,
                          onPressed: !provider.canClaimDailyReward
                              ? null
                              : () {
                                  if (provider.claimDailyReward(50)) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('🎉 Claimed 50 Coins!'),
                                        backgroundColor: GameColors.freshGreen,
                                      ),
                                    );
                                  }
                                },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 4. MYSTERY CHEST UNLOCK SECTION
                  const Text(
                    'MYSTERY CHEST',
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: GameColors.navyText,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: RewardChestWidget(
                      isOpen: !provider.canClaimDailyChest,
                      onOpen: () {
                        if (provider.claimDailyChest(100)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                '🎁 Opened Chest! Earned +100 Coins!',
                              ),
                              backgroundColor: GameColors.sunnyYellow,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showRewardedAdModal(BuildContext context, GameProvider provider) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _RewardedAdDialog(provider: provider),
    );
  }
}

class _RewardedAdDialog extends StatefulWidget {
  final GameProvider provider;

  const _RewardedAdDialog({required this.provider});

  @override
  State<_RewardedAdDialog> createState() => _RewardedAdDialogState();
}

class _RewardedAdDialogState extends State<_RewardedAdDialog> {
  int _countdown = 3;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 1) {
        setState(() => _countdown--);
      } else {
        _timer.cancel();
        widget.provider.watchAdForGems();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Rewarded Video Finished! +5 Free Gems 💎 added!'),
            backgroundColor: GameColors.gemPurple,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: GameColors.surfaceWarm,
      title: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('📺 ', style: TextStyle(fontSize: 22)),
          Text(
            'REWARDED AD PLAYING',
            style: TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: GameColors.navyText,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.play_circle_fill_rounded,
                  size: 44,
                  color: GameColors.sunnyYellow,
                ),
                const SizedBox(height: 6),
                Text(
                  'Reward in $_countdown seconds...',
                  style: const TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Earn +5 Free Gems 💎 upon completion!',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: GameColors.navyTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
