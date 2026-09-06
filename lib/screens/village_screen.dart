import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/building_model.dart';
import '../providers/game_provider.dart';
import '../theme/colors.dart';
import '../widgets/hut_upgrade_dialog.dart';

class VillageScreen extends StatelessWidget {
  const VillageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, provider, child) {
        final player = provider.player;
        final buildings = provider.activeBuildings;

        return Scaffold(
          backgroundColor: GameColors.background,
          body: SafeArea(
            child: CustomScrollView(
            slivers: [
              // Village Header Banner
              SliverToBoxAdapter(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [GameColors.tealDark, GameColors.skyBlueDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(28),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '🏡 Math Kingdom Village',
                                style: TextStyle(
                                  fontFamily: 'Fredoka',
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Build huts & unlock kingdom perks!',
                                style: TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 13,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                          // Wood Logs Inventory Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.4)),
                            ),
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/images/wood_log.png',
                                  height: 22,
                                  fit: BoxFit.contain,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${player.woodLogs} Wood',
                                  style: const TextStyle(
                                    fontFamily: 'Fredoka',
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // How to earn wood tip card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: GameColors.sunnyYellow.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: GameColors.yellowDark.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/images/wood_log.png',
                          height: 26,
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Earn Wood Logs after completing math quests! Use them with coins to build huts.',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: GameColors.navyText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // List of Village Buildings
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final building = buildings[index];
                      return _buildBuildingCard(context, building, provider);
                    },
                    childCount: buildings.length,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
      },
    );
  }

  Widget _buildBuildingCard(
      BuildContext context, BuildingModel building, GameProvider provider) {
    final player = provider.player;
    final isMax = building.isMaxStage;
    final canAfford = !isMax &&
        player.coins >= building.nextStageCoinCost &&
        player.woodLogs >= building.nextStageWoodCost;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: GameColors.surfaceWarm,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: building.currentStage > 0
              ? GameColors.turquoise.withOpacity(0.5)
              : GameColors.cardBorder,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: GameColors.navyText.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Hut Icon Container with stage visual status
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: _getStageBgColor(building.currentStage),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _getStageBorderColor(building.currentStage),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      building.currentStage == 0 ? '🔨' : building.iconEmoji,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Title and Stage Badge
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        building.name,
                        style: const TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: GameColors.navyText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isMax
                                  ? GameColors.freshGreen
                                  : (building.currentStage > 0
                                      ? GameColors.skyBlue
                                      : GameColors.navyTextMuted),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              building.currentStageTitle,
                              style: const TextStyle(
                                fontFamily: 'Fredoka',
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Stage ${building.currentStage}/${building.maxStage}',
                            style: const TextStyle(
                              fontFamily: 'Nunito',
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
              ],
            ),
            const SizedBox(height: 12),
            Text(
              building.description,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 13,
                color: GameColors.navyTextSecondary,
              ),
            ),
            const SizedBox(height: 12),
            // Perk Info & Action Button Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Text('✨ ', style: TextStyle(fontSize: 14)),
                      Expanded(
                        child: Text(
                          building.perkDescription,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Fredoka',
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: GameColors.yellowDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => HutUpgradeDialog(building: building),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isMax
                        ? GameColors.freshGreen
                        : (canAfford
                            ? GameColors.turquoise
                            : GameColors.skyBlue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                  ),
                  child: Text(
                    isMax
                        ? 'VIEW'
                        : (building.currentStage == 0
                            ? 'BUILD 🛠️'
                            : 'UPGRADE 🪵'),
                    style: const TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStageBgColor(int stage) {
    switch (stage) {
      case 0:
        return GameColors.cardBorder.withOpacity(0.3);
      case 1:
        return GameColors.streakOrange.withOpacity(0.15);
      case 2:
        return GameColors.skyBlue.withOpacity(0.15);
      case 3:
      default:
        return GameColors.freshGreen.withOpacity(0.15);
    }
  }

  Color _getStageBorderColor(int stage) {
    switch (stage) {
      case 0:
        return GameColors.cardBorder;
      case 1:
        return GameColors.streakOrange;
      case 2:
        return GameColors.skyBlue;
      case 3:
      default:
        return GameColors.freshGreen;
    }
  }
}
