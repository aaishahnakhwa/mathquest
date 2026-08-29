import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/world_model.dart';
import '../models/level_model.dart';
import '../theme/colors.dart';
import '../widgets/map_path_painter.dart';
import '../widgets/map_background_painter.dart';
import '../widgets/village_buildings_overlay.dart';
import '../widgets/level_node_widget.dart';
import '../widgets/game_button.dart';
import '../widgets/world_preview_modal.dart';
import 'gameplay_screen.dart';

class AdventureMapScreen extends StatelessWidget {
  const AdventureMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, provider, child) {
        final player = provider.player;
        final worlds = provider.worlds;

        return Stack(
          children: [
            // Main Vertically Scrollable Map with Full Illustrated Background
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                children: [
                  // Map Header Title
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'ADVENTURE MAP',
                              style: TextStyle(
                                fontFamily: 'Fredoka',
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: GameColors.navyText,
                              ),
                            ),
                            Text(
                              'Explore worlds and level up!',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 13,
                                color: GameColors.navyTextSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            gradient: GameColors.jellyYellowGradient,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: GameColors.jellyYellowDark, width: 2.5),
                            boxShadow: [
                              BoxShadow(
                                color: GameColors.jellyYellowDark.withValues(alpha: 0.4),
                                blurRadius: 6,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Text('⭐ ', style: TextStyle(fontSize: 16)),
                              Text(
                                '${player.totalStars} Stars',
                                style: const TextStyle(
                                  fontFamily: 'Fredoka',
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black38,
                                      offset: Offset(1, 1.5),
                                      blurRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Render Worlds vertically
                  ...worlds.map((world) => _buildWorldSection(context, provider, world)),
                ],
              ),
            ),

            // Floating Game Menu Sidebar (Quests, Shop, Rewards, Badges)
            Positioned(
              right: 12,
              top: 80,
              child: Column(
                children: [
                  _buildSideMenuButton(
                    emoji: '📜',
                    label: 'Quests',
                    onTap: () => provider.setCurrentTab(0),
                  ),
                  const SizedBox(height: 10),
                  _buildSideMenuButton(
                    emoji: '🛒',
                    label: 'Shop',
                    onTap: () => provider.setCurrentTab(4),
                  ),
                  const SizedBox(height: 10),
                  _buildSideMenuButton(
                    emoji: '🎁',
                    label: 'Rewards',
                    onTap: () => provider.setCurrentTab(2),
                  ),
                  const SizedBox(height: 10),
                  _buildSideMenuButton(
                    emoji: '🏆',
                    label: 'Badges',
                    onTap: () => provider.setCurrentTab(3),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWorldSection(
    BuildContext context,
    GameProvider provider,
    WorldModel world,
  ) {
    final player = provider.player;
    final isWorldUnlocked = player.unlockedWorldIds.contains(world.id);

    final double containerWidth = MediaQuery.of(context).size.width - 32;
    final double totalHeight = 680.0; // Fixed height matching background artwork aspect ratio

    // PRECISE NODE POSITIONS SYNCED WITH THE SANDY DIRT TRAIL IN THE BACKGROUND IMAGE!
    final List<Offset> nodePositions = [
      Offset(containerWidth * 0.18, 50),   // Level 1: Top-Left Mountain Trail
      Offset(containerWidth * 0.34, 210),  // Level 2: Middle Trail Clearing Beside Trees
      Offset(containerWidth * 0.64, 340),  // Level 3: Trail Passing Right of Central Trees
      Offset(containerWidth * 0.26, 490),  // Level 4: Trail Passing Left of Campsite
      Offset(containerWidth * 0.74, 610),  // Level 5: Bottom-Right Cave Boss Entrance
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 30),
      child: Column(
        children: [
          // World Title Banner Card (Tap to Preview)
          GestureDetector(
            onTap: () => WorldPreviewModal.show(
              context,
              world: world,
              player: player,
              isUnlocked: isWorldUnlocked,
            ),
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [world.primaryColor, world.secondaryColor],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: world.primaryColor.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Text(world.iconEmoji, style: const TextStyle(fontSize: 40)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'WORLD ${world.worldNumber}',
                              style: const TextStyle(
                                fontFamily: 'Fredoka',
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white70,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.info_outline_rounded,
                                color: Colors.white70, size: 14),
                          ],
                        ),
                        Text(
                          world.name,
                          style: const TextStyle(
                            fontFamily: 'Fredoka',
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          world.subtitle,
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isWorldUnlocked)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.black26,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.lock_rounded,
                          color: Colors.white, size: 24),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'PREVIEW',
                        style: TextStyle(
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
          ),

          // Winding Level Path & User's Uploaded Illustrated Background Layer + Dynamic Village Overlay
          if (isWorldUnlocked)
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                height: totalHeight,
                width: containerWidth,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: GameColors.sunnyYellow, width: 3.5),
                  boxShadow: [
                    BoxShadow(
                      color: GameColors.navyText.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: containerWidth,
                  height: totalHeight,
                  child: Stack(
                    children: [
                      // 1. HIGH-RESOLUTION BACKGROUND MAP IMAGE / CUSTOM WORLD PAINTER
                      Positioned.fill(
                        child: world.id == 'world_1'
                            ? Image.asset(
                                'assets/images/world_map_bg.jpg',
                                fit: BoxFit.cover,
                                filterQuality: FilterQuality.high,
                                errorBuilder: (context, error, stackTrace) {
                                  return CustomPaint(
                                    size: Size(containerWidth, totalHeight),
                                    painter: MapBackgroundPainter(
                                      worldId: world.id,
                                      completedLevelsCount: world.levels
                                          .where((l) => player.completedLevelIds.contains(l.id))
                                          .length,
                                    ),
                                  );
                                },
                              )
                            : CustomPaint(
                                size: Size(containerWidth, totalHeight),
                                painter: MapBackgroundPainter(
                                  worldId: world.id,
                                  completedLevelsCount: world.levels
                                      .where((l) => player.completedLevelIds.contains(l.id))
                                      .length,
                                ),
                              ),
                      ),

                      // 2. DYNAMIC VILLAGE BUILDINGS OVERLAY (ONLY FOR WORLD 1)
                      if (world.id == 'world_1')
                        Positioned.fill(
                          child: VillageBuildingsOverlay(
                            worldId: world.id,
                            completedCount: world.levels
                                .where((l) => player.completedLevelIds.contains(l.id))
                                .length,
                            width: containerWidth,
                            height: totalHeight,
                          ),
                        ),

                      // 3. Winding Curved Path Overlay Painter (100% SYNCED WITH BACKGROUND DIRT TRAIL!)
                      CustomPaint(
                        size: Size(containerWidth, totalHeight),
                        painter: MapPathPainter(
                          nodePositions: nodePositions,
                          activeIndex: 0,
                          pathColor: GameColors.sunnyYellow,
                        ),
                      ),

                      // 4. Level Nodes positioned along path
                      ...List.generate(world.levels.length, (index) {
                        final level = world.levels[index];
                        final pos = nodePositions[index];

                        final isCompleted =
                            player.completedLevelIds.contains(level.id);
                        final isUnlocked = provider.isLevelUnlocked(level);
                        final earnedStars = player.levelStars[level.id] ?? 0;

                        final isCurrent = isUnlocked &&
                            !isCompleted &&
                            (index == 0 ||
                                player.completedLevelIds.contains(
                                    world.levels[index - 1].id));

                        return Positioned(
                          left: pos.dx - 36,
                          top: pos.dy - 36,
                          child: LevelNodeWidget(
                            level: level,
                            isUnlocked: isUnlocked,
                            isCompleted: isCompleted,
                            isCurrent: isCurrent,
                            earnedStars: earnedStars,
                            playerAvatarId: player.avatarId,
                            playerHatId: player.equippedHatId,
                            onTap: () => _showLevelDetailsSheet(
                              context,
                              provider,
                              level,
                              isUnlocked,
                              earnedStars,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: GameColors.nodeLocked.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: GameColors.nodeLocked, width: 2),
              ),
              child: Column(
                children: [
                  const Text('🔒', style: TextStyle(fontSize: 40)),
                  const SizedBox(height: 8),
                  Text(
                    'Unlock requirement: ${world.reqStarsToUnlock} Stars',
                    style: const TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: GameColors.navyTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    world.description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 13,
                      color: GameColors.navyTextMuted,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GameButton(
                    text: 'PREVIEW WORLD & LEVELS 📜',
                    backgroundColor: GameColors.skyBlueLight,
                    shadowColor: GameColors.skyBlue,
                    textColor: GameColors.skyBlueDark,
                    height: 42,
                    fontSize: 12,
                    onPressed: () => WorldPreviewModal.show(
                      context,
                      world: world,
                      player: player,
                      isUnlocked: false,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSideMenuButton({
    required String emoji,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: const [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: GameColors.jellyYellowDark, width: 2),
          boxShadow: [
            BoxShadow(
              color: GameColors.jellyYellowDark.withValues(alpha: 0.3),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: GameColors.navyText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLevelDetailsSheet(
    BuildContext context,
    GameProvider provider,
    LevelModel level,
    bool isUnlocked,
    int earnedStars,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: GameColors.surfaceWarm,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            border: Border(
              top: BorderSide(color: GameColors.sunnyYellow, width: 4),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'LEVEL ${level.levelNumber}',
                style: const TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: GameColors.skyBlueDark,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                level.title,
                style: const TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: GameColors.navyText,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: GameColors.skyBlueLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Topic: ${level.topic}',
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: GameColors.skyBlueDark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: GameColors.freshGreenLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      level.difficulty,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: GameColors.freshGreenDark,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  final hasStar = index < earnedStars;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Icon(
                      hasStar ? Icons.star_rounded : Icons.star_border_rounded,
                      size: 36,
                      color: hasStar
                          ? GameColors.coinGold
                          : Colors.grey.shade400,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
              GameButton(
                text: 'START QUEST',
                icon: const Text('⚔️', style: TextStyle(fontSize: 20)),
                backgroundColor: GameColors.freshGreen,
                shadowColor: GameColors.freshGreenDark,
                textColor: Colors.white,
                onPressed: () {
                  Navigator.pop(context);
                  provider.startLevel(level);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GameplayScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
