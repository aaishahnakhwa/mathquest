import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/game_provider.dart';
import '../models/world_model.dart';
import '../models/level_model.dart';
import '../theme/colors.dart';
import '../widgets/ambient_butterfly.dart';
import '../widgets/ambient_leaf_field.dart';
import '../widgets/map_background_painter.dart';
import '../widgets/village_buildings_overlay.dart';
import '../widgets/level_node_widget.dart';
import '../widgets/game_button.dart';
import '../widgets/world_three_lumina_field.dart';
import 'gameplay_screen.dart';
import 'foundation_builder_screen.dart';

class AdventureMapScreen extends StatefulWidget {
  const AdventureMapScreen({super.key});

  @override
  State<AdventureMapScreen> createState() => _AdventureMapScreenState();
}

class _AdventureMapScreenState extends State<AdventureMapScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _cloudAnimationController;

  @override
  void initState() {
    super.initState();
    _cloudAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 150), () {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    });
  }

  @override
  void dispose() {
    _cloudAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, provider, child) {
        final player = provider.player;
        final activeWorlds = provider.worlds;

        final double screenWidth = MediaQuery.of(context).size.width;
        final orderedWorlds = activeWorlds.reversed.toList();
        final seamOffsets = <double>[];
        var accumulatedHeight = 0.0;
        for (var index = 0; index < orderedWorlds.length - 1; index++) {
          accumulatedHeight +=
              screenWidth * _mapAspectForWorld(orderedWorlds[index].id);
          seamOffsets.add(accumulatedHeight);
        }
        final double cloudHeight = screenWidth * (341.0 / 1024.0);

        return Stack(
          children: [
            // Main Vertically Scrollable Map with Full Illustrated Background
            SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.only(top: 10, bottom: 0),
              child: Column(
                children: [
                  // Map Header Title
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
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
                            horizontal: 14,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            gradient: GameColors.jellyYellowGradient,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: GameColors.jellyYellowDark,
                              width: 2.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: GameColors.jellyYellowDark.withValues(
                                  alpha: 0.4,
                                ),
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

                  // Render the highest world first and mask every map seam with
                  // the existing animated cloud transition asset.
                  AnimatedBuilder(
                    animation: _cloudAnimationController,
                    builder: (context, child) {
                      final val = _cloudAnimationController.value;
                      final floatY = math.sin(val * math.pi * 2) * 6.0;
                      final floatX = math.cos(val * math.pi * 2) * 14.0;

                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Column(
                            children: orderedWorlds
                                .map(
                                  (world) => _buildWorldSection(
                                    context,
                                    provider,
                                    world,
                                  ),
                                )
                                .toList(),
                          ),

                          for (final seamTop in seamOffsets) ...[
                            // 1. Animated Left Edge Cloud Replica
                            Positioned(
                              top:
                                  seamTop -
                                  (cloudHeight * 0.95) +
                                  (floatY * 0.7),
                              left: -screenWidth * 0.15 - (floatX * 0.6),
                              width: screenWidth * 0.75,
                              height: cloudHeight * 1.1,
                              child: IgnorePointer(
                                child: Image.asset(
                                  'assets/images/map_cloud_transition.png',
                                  fit: BoxFit.fill,
                                  filterQuality: FilterQuality.high,
                                ),
                              ),
                            ),

                            // 2. Animated Right Edge Cloud Replica (Mirrored)
                            Positioned(
                              top:
                                  seamTop -
                                  (cloudHeight * 0.85) -
                                  (floatY * 0.7),
                              right: -screenWidth * 0.15 + (floatX * 0.6),
                              width: screenWidth * 0.75,
                              height: cloudHeight * 1.1,
                              child: IgnorePointer(
                                child: Transform.scale(
                                  scaleX: -1,
                                  child: Image.asset(
                                    'assets/images/map_cloud_transition.png',
                                    fit: BoxFit.fill,
                                    filterQuality: FilterQuality.high,
                                  ),
                                ),
                              ),
                            ),

                            // 3. Animated Main Center Cloud Transition
                            Positioned(
                              top: seamTop - (cloudHeight * 0.70) + floatY,
                              left: floatX,
                              right: -floatX,
                              height: cloudHeight,
                              child: IgnorePointer(
                                child: Image.asset(
                                  'assets/images/map_cloud_transition.png',
                                  width: screenWidth,
                                  height: cloudHeight,
                                  fit: BoxFit.fill,
                                  filterQuality: FilterQuality.high,
                                ),
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                  ),
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

  double _mapAspectForWorld(String worldId) {
    if (worldId == 'world_3') return 1676.0 / 941.0;
    if (worldId == 'world_2') return 1024.0 / 576.0;
    return 1024.0 / 681.0;
  }

  Widget _buildWorldSection(
    BuildContext context,
    GameProvider provider,
    WorldModel world,
  ) {
    final player = provider.player;
    final isWorldUnlocked = player.unlockedWorldIds.contains(world.id);

    final double containerWidth = MediaQuery.of(context).size.width;
    final String? bgAssetPath = world.id == 'world_1'
        ? 'assets/images/world_map_bg.jpg'
        : world.id == 'world_2'
        ? 'assets/images/world_2_map_bg.jpg'
        : world.id == 'world_3'
        ? 'assets/images/world_3_map_bg.png'
        : null;

    final double mapAspect = _mapAspectForWorld(world.id);
    final double totalHeight = containerWidth * mapAspect;

    // PRECISE NODE POSITIONS SYNCED 1:1 WITH THE BACKGROUND ARTWORK BADGES!
    final List<Offset> nodePositions = world.id == 'world_3'
        ? [
            Offset(
              containerWidth * 0.4612,
              totalHeight * 0.7601,
            ), // Level 11 (lowest pedestal)
            Offset(
              containerWidth * 0.5058,
              totalHeight * 0.5704,
            ), // Level 12 (second-lowest pedestal)
          ]
        : world.id == 'world_2'
        ? [
            Offset(
              containerWidth * 0.5022,
              totalHeight * 0.8104,
            ), // Level 6 (Pedestal 1)
            Offset(
              containerWidth * 0.4956,
              totalHeight * 0.6264,
            ), // Level 7 (Pedestal 2)
            Offset(
              containerWidth * 0.5391,
              totalHeight * 0.4514,
            ), // Level 8 (Pedestal 3)
            Offset(
              containerWidth * 0.5112,
              totalHeight * 0.2747,
            ), // Level 9 (Pedestal 4)
            Offset(
              containerWidth * 0.5215,
              totalHeight * 0.1387,
            ), // Level 10 (Pedestal 5)
          ]
        : [
            Offset(
              containerWidth * 0.5628,
              totalHeight * 0.8798,
            ), // Level 1 (Circle 1)
            Offset(
              containerWidth * 0.4436,
              totalHeight * 0.7183,
            ), // Level 2 (Circle 2)
            Offset(
              containerWidth * 0.5754,
              totalHeight * 0.5171,
            ), // Level 3 (Circle 3)
            Offset(
              containerWidth * 0.4186,
              totalHeight * 0.3421,
            ), // Level 4 (Circle 4)
            Offset(
              containerWidth * 0.4362,
              totalHeight * 0.1240,
            ), // Level 5 (Circle 5)
          ];

    return SizedBox(
      height: totalHeight,
      width: containerWidth,
      child: Stack(
        children: [
          // 1. HIGH-RESOLUTION BACKGROUND MAP IMAGE / CUSTOM WORLD PAINTER
          Positioned.fill(
            child: bgAssetPath != null
                ? Image.asset(
                    bgAssetPath,
                    fit: BoxFit.fill,
                    filterQuality: FilterQuality.high,
                    errorBuilder: (context, error, stackTrace) {
                      return CustomPaint(
                        size: Size(containerWidth, totalHeight),
                        painter: MapBackgroundPainter(
                          worldId: world.id,
                          completedLevelsCount: world.levels
                              .where(
                                (l) => player.completedLevelIds.contains(l.id),
                              )
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

          // Ambient wildlife stays above the artwork and below every map control.
          if (world.id == 'world_3')
            Positioned.fill(
              child: WorldThreeLuminaField(
                animation: _cloudAnimationController,
                mapWidth: containerWidth,
                mapHeight: totalHeight,
              ),
            ),
          if (world.id == 'world_1')
            Positioned.fill(
              child: AmbientLeafField(
                animation: _cloudAnimationController,
                mapWidth: containerWidth,
                mapHeight: totalHeight,
              ),
            ),
          if (world.id == 'world_1')
            Positioned.fill(
              child: AmbientButterfly(
                id: 'meadow-orange',
                animation: _cloudAnimationController,
                mapWidth: containerWidth,
                mapHeight: totalHeight,
              ),
            ),
          if (world.id == 'world_1')
            Positioned.fill(
              child: AmbientButterfly(
                id: 'waterside-yellow',
                animation: _cloudAnimationController,
                mapWidth: containerWidth,
                mapHeight: totalHeight,
                frames: AmbientButterfly.yellowFrameAssets,
                flightArea: ButterflyFlightArea.upperLeftWaterside,
                wingPhaseOffset: 0.37,
                sizeFactor: 0.062,
                initialRouteVariant: 1,
              ),
            ),
          if (world.id == 'world_1')
            Positioned.fill(
              child: AmbientButterfly(
                id: 'grove-blue',
                animation: _cloudAnimationController,
                mapWidth: containerWidth,
                mapHeight: totalHeight,
                frames: AmbientButterfly.blueFrameAssets,
                flightArea: ButterflyFlightArea.lowerLeftGrove,
                wingPhaseOffset: 0.68,
                sizeFactor: 0.058,
                initialRouteVariant: 2,
              ),
            ),

          // 2. DYNAMIC VILLAGE BUILDINGS OVERLAY (ONLY FOR WORLD 1)
          if (world.id == 'world_1')
            Positioned.fill(
              child: VillageBuildingsOverlay(
                worldId: world.id,
                width: containerWidth,
                height: totalHeight,
              ),
            ),

          // 3. Level Nodes positioned along path
          ...List.generate(world.levels.length, (index) {
            final level = world.levels[index];
            final pos = nodePositions[index];

            final isCompleted = player.completedLevelIds.contains(level.id);
            final isUnlocked = provider.isLevelUnlocked(level);
            final earnedStars = player.levelStars[level.id] ?? 0;

            final isCurrent =
                isUnlocked &&
                !isCompleted &&
                (index == 0 ||
                    player.completedLevelIds.contains(
                      world.levels[index - 1].id,
                    ));

            final isHouseBuilt = provider.isLevelHouseComplete(level);

            return Positioned(
              left: pos.dx - 29,
              top: pos.dy - 21,
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
                onBuildTap:
                    (world.id == 'world_1' && isCompleted && !isHouseBuilt)
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                FoundationBuilderScreen(level: level),
                          ),
                        );
                      }
                    : null,
              ),
            );
          }),

          // 4. TRANSLUCENT BLACK OVERLAY FOR LOCKED WORLDS (Covers entire locked map + locked button badges)
          if (!isWorldUnlocked)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(color: Colors.black.withValues(alpha: 0.45)),
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
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: const [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: GameColors.jellyYellowDark, width: 1.8),
          boxShadow: [
            BoxShadow(
              color: GameColors.jellyYellowDark.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 9,
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
          decoration: BoxDecoration(
            color: GameColors.surfaceWarm,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(color: GameColors.sunnyYellow, width: 3),
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
                      horizontal: 10,
                      vertical: 4,
                    ),
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
                      horizontal: 10,
                      vertical: 4,
                    ),
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
              if (level.worldId == 'world_1' &&
                  provider.player.completedLevelIds.contains(level.id)) ...[
                Builder(
                  builder: (context) {
                    final houseStage = provider.levelHouseStage(level);
                    final isHouseBuilt = provider.isLevelHouseComplete(level);
                    if (!isHouseBuilt) {
                      return GameButton(
                        text: houseStage == 0
                            ? 'BUILD HOUSE 🛠️'
                            : 'CONTINUE BUILD $houseStage/${GameProvider.levelHouseFinalStage}',
                        icon: Image.asset(
                          'assets/images/wood_log.png',
                          height: 20,
                        ),
                        backgroundColor: GameColors.skyBlue,
                        shadowColor: GameColors.skyBlueDark,
                        textColor: Colors.white,
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
                      );
                    } else {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: GameColors.freshGreen.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: GameColors.freshGreen,
                            width: 2,
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'HOUSE STAGE COMPLETED ✅',
                              style: TextStyle(
                                fontFamily: 'Fredoka',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: GameColors.freshGreenDark,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 12),
              ],
              GameButton(
                text: provider.player.completedLevelIds.contains(level.id)
                    ? 'REPLAY QUEST'
                    : 'PLAY QUEST',
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
