import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../theme/colors.dart';
import 'building_painter.dart';
import 'building_construction_widget.dart';

class VillageBuildingsOverlay extends StatefulWidget {
  final String worldId;
  final int completedCount;
  final double width;
  final double height;

  const VillageBuildingsOverlay({
    super.key,
    required this.worldId,
    required this.completedCount,
    required this.width,
    required this.height,
  });

  @override
  State<VillageBuildingsOverlay> createState() =>
      _VillageBuildingsOverlayState();
}

class _VillageBuildingsOverlayState extends State<VillageBuildingsOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  int? _getStageFromLevelId(String? levelId) {
    if (levelId == null) return null;
    switch (levelId) {
      case 'w1_l1':
        return 1;
      case 'w1_l2':
        return 2;
      case 'w1_l3':
        return 3;
      case 'w1_l4':
        return 4;
      case 'w1_l5':
        return 5;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Village building elements ONLY exist for World 1!
    if (widget.worldId != 'world_1') {
      return const SizedBox.shrink();
    }

    final provider = Provider.of<GameProvider>(context);
    final cutsceneStage =
        _getStageFromLevelId(provider.pendingConstructionLevelId);

    // Active stage where the Persistent Builder Worker is currently working!
    final activeWorkerStage = (widget.completedCount + 1).clamp(1, 5);

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _animController,
        builder: (context, child) {
          final animVal = _animController.value;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              // STAGE 1: STONE AGE TIMBER COTTAGE & CAMPFIRE
              if (widget.completedCount >= 1)
                Positioned(
                  left: widget.width * 0.48,
                  top: 60,
                  child: Column(
                    children: [
                      _buildEraBadge('🛖 Stone Age'),
                      const SizedBox(height: 2),
                      CustomPaint(
                        size: const Size(72, 72),
                        painter: BuildingPainter(stage: 1, animValue: animVal),
                      ),
                    ],
                  ),
                ),

              // STAGE 2: TIMBER & WINDMILL
              if (widget.completedCount >= 2)
                Positioned(
                  left: widget.width * 0.02,
                  top: 120,
                  child: Column(
                    children: [
                      _buildEraBadge('🌾 Timber Age'),
                      const SizedBox(height: 2),
                      CustomPaint(
                        size: const Size(72, 72),
                        painter: BuildingPainter(stage: 2, animValue: animVal),
                      ),
                    ],
                  ),
                ),

              // STAGE 3: IRON AGE SMITHY & MARKET
              if (widget.completedCount >= 3)
                Positioned(
                  left: widget.width * 0.22,
                  top: 360,
                  child: Column(
                    children: [
                      _buildEraBadge('⚒️ Iron Age'),
                      const SizedBox(height: 2),
                      CustomPaint(
                        size: const Size(72, 72),
                        painter: BuildingPainter(stage: 3, animValue: animVal),
                      ),
                    ],
                  ),
                ),

              // STAGE 4: CASTLE AGE FORTRESS
              if (widget.completedCount >= 4)
                Positioned(
                  left: widget.width * 0.58,
                  top: 460,
                  child: Column(
                    children: [
                      _buildEraBadge('🏰 Castle Age'),
                      const SizedBox(height: 2),
                      CustomPaint(
                        size: const Size(76, 76),
                        painter: BuildingPainter(stage: 4, animValue: animVal),
                      ),
                    ],
                  ),
                ),

              // STAGE 5: IMPERIAL CITADEL MONUMENT
              if (widget.completedCount >= 5)
                Positioned(
                  left: widget.width * 0.30,
                  top: 580,
                  child: Column(
                    children: [
                      _buildEraBadge('👑 Imperial Age'),
                      const SizedBox(height: 2),
                      CustomPaint(
                        size: const Size(80, 80),
                        painter: BuildingPainter(stage: 5, animValue: animVal),
                      ),
                    ],
                  ),
                ),

              // PERSISTENT ANIMATED BUILDER WORKER (ALWAYS WORKING BESIDE ACTIVE CONSTRUCTION PLOT!)
              Positioned(
                left: _getWorkerX(activeWorkerStage, widget.width),
                top: _getWorkerY(activeWorkerStage),
                child: PersistentBuilderManWidget(
                  activeStage: activeWorkerStage,
                  animValue: animVal,
                ),
              ),

              // LEVEL COMPLETE UPGRADE CUTSCENE ANIMATION
              if (cutsceneStage != null)
                Positioned(
                  left: _getStageX(cutsceneStage, widget.width),
                  top: _getStageY(cutsceneStage),
                  child: BuildingConstructionWidget(
                    stage: cutsceneStage,
                    onComplete: () {
                      provider.clearPendingConstruction();
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEraBadge(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: GameColors.navyText.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: GameColors.sunnyYellow, width: 1.5),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Fredoka',
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  double _getWorkerX(int stage, double containerWidth) {
    switch (stage) {
      case 1:
        return containerWidth * 0.48; // Below Stone Age Hut
      case 2:
        return containerWidth * 0.03; // Below Timber Windmill
      case 3:
        return containerWidth * 0.05; // Far left grassy clearing away from Node 3 & Path!
      case 4:
        return containerWidth * 0.58; // Below Castle Fortress
      case 5:
        return containerWidth * 0.24; // Below Citadel Monument
      default:
        return containerWidth * 0.45;
    }
  }

  double _getWorkerY(int stage) {
    switch (stage) {
      case 1:
        return 125;
      case 2:
        return 185;
      case 3:
        return 400;
      case 4:
        return 515;
      case 5:
        return 625;
      default:
        return 100;
    }
  }

  double _getStageX(int stage, double containerWidth) {
    switch (stage) {
      case 1:
        return containerWidth * 0.46;
      case 2:
        return containerWidth * 0.01;
      case 3:
        return containerWidth * 0.20;
      case 4:
        return containerWidth * 0.56;
      case 5:
        return containerWidth * 0.28;
      default:
        return containerWidth * 0.4;
    }
  }

  double _getStageY(int stage) {
    switch (stage) {
      case 1:
        return 50;
      case 2:
        return 110;
      case 3:
        return 350;
      case 4:
        return 450;
      case 5:
        return 570;
      default:
        return 200;
    }
  }
}
