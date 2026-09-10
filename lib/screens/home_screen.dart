import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/game_provider.dart';
import '../theme/colors.dart';
import '../widgets/game_button.dart';
import '../widgets/math_guide_widget.dart';
import 'gameplay_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, provider, child) {
        final player = provider.player;
        final currentWorld = provider.worlds.firstWhere(
          (w) => w.id == player.currentWorldId,
          orElse: () => provider.worlds.first,
        );

        // Find next playable level
        final nextLevel = currentWorld.levels.firstWhere(
          (l) => !player.completedLevelIds.contains(l.id),
          orElse: () => currentWorld.levels.last,
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header Greeting
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome Back, ${player.name}!',
                        style: const TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: GameColors.navyText,
                        ),
                      ),
                      const Text(
                        'Ready for today\'s math quest?',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 14,
                          color: GameColors.navyTextSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Professor Owl Math Guide Companion Speech
              const MathGuideWidget(
                text: 'Mastering math opens doors to exciting worlds! Tap Continue Adventure to dive into your next quest.',
              ),
              const SizedBox(height: 20),

              // Main Illustrated Environment Showcase Card (Featuring High-Res World Map Image)
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: const Color(0xFFF59E0B),
                    width: 3.5,
                  ),
                  boxShadow: const [
                    BoxShadow(color: Color(0xFFD97706), offset: Offset(0, 6)),
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 16,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24.5),
                  child: Stack(
                    children: [
                      // 1. High-Res Isometric Fantasy World Map Image
                      Image.asset(
                        'assets/images/world_map.jpg',
                        height: 240,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),

                      // 2. Gradient Overlay for Crisp Text Readability
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.65),
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.85),
                              ],
                              stops: const [0.0, 0.4, 1.0],
                            ),
                          ),
                        ),
                      ),

                      // 3. Card Content & Level Controls
                      Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // World Header Badge
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0F172A)
                                        .withValues(alpha: 0.8),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFFF59E0B),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        currentWorld.iconEmoji,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'WORLD ${currentWorld.worldNumber}: ${currentWorld.name.toUpperCase()}',
                                        style: const TextStyle(
                                          fontFamily: 'Fredoka',
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFFEF08A),
                                          letterSpacing: 0.6,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 55),

                            // Next Level Info Pill & CTA Button
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '🎯 Next: Level ${nextLevel.levelNumber} - ${nextLevel.title}',
                                    style: const TextStyle(
                                      fontFamily: 'Fredoka',
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Primary Hero CTA: CONTINUE ADVENTURE
                                GameButton(
                                  text: 'CONTINUE ADVENTURE',
                                  icon: const Text(
                                    '🚀',
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  backgroundColor: GameColors.freshGreen,
                                  shadowColor: GameColors.freshGreenDark,
                                  textColor: Colors.white,
                                  height: 54,
                                  fontSize: 17,
                                  onPressed: () {
                                    provider.startLevel(nextLevel);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const GameplayScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Daily Challenge Section
              const Text(
                'DAILY CHALLENGE',
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: GameColors.navyText,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: GameColors.surfaceWarm,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: GameColors.sunnyYellow, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: GameColors.navyText.withValues(alpha: 0.06),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: GameColors.sunnyYellow.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Text('⚡', style: TextStyle(fontSize: 28)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Complete 5 Math Challenges',
                            style: TextStyle(
                              fontFamily: 'Fredoka',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: GameColors.navyText,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Reward: +100 XP • +25 Coins • +1 Gem',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: GameColors.yellowDark,
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
                        color: GameColors.freshGreen,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Text(
                        'GO!',
                        style: TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Streak & Stats Row
              Row(
                children: [
                  Expanded(
                    child: _buildStatTile(
                      icon: '🔥',
                      title: 'STREAK',
                      value: '${player.streakDays} Days',
                      color: GameColors.streakOrange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatTile(
                      icon: '⭐',
                      title: 'STARS',
                      value: '${player.totalStars} Earned',
                      color: GameColors.coinGold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatTile({
    required String icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.08), blurRadius: 6),
        ],
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: GameColors.navyText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
