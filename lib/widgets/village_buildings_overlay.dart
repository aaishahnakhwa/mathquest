import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

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

  // Calibrated Coordinates Map for all 5 Village Plots
  final Map<int, Offset> _plotCoords = {
    1: const Offset(0.336, 0.830), // Plot 1
    2: const Offset(0.673, 0.628), // Locked Plot 2 Exact Position
    3: const Offset(0.360, 0.438), // Locked Plot 3 Exact Position
    4: const Offset(0.659, 0.277), // Locked Plot 4 Exact Position
    5: const Offset(0.310, 0.175), // Plot 5
  };

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

  @override
  Widget build(BuildContext context) {
    if (widget.worldId != 'world_1') {
      return const SizedBox.shrink();
    }

    final provider = Provider.of<GameProvider>(context);

    // Check build completion status for each level's house stage
    // Figures ONLY show after the user has actually built that stage!
    final bool stage1Built =
        (provider.player.buildingStages['hut_level_1'] ??
         provider.player.buildingStages['hut_w1_l1'] ?? 0) > 0;

    final bool stage2Built =
        (provider.player.buildingStages['hut_level_2'] ??
         provider.player.buildingStages['hut_w1_l2'] ?? 0) > 0;

    final bool stage3Built =
        (provider.player.buildingStages['hut_level_3'] ??
         provider.player.buildingStages['hut_w1_l3'] ?? 0) > 0;

    final bool stage4Built =
        (provider.player.buildingStages['hut_level_4'] ??
         provider.player.buildingStages['hut_w1_l4'] ?? 0) > 0;

    final bool stage5Built =
        (provider.player.buildingStages['hut_level_5'] ??
         provider.player.buildingStages['hut_w1_l5'] ?? 0) > 0;

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _animController,
        builder: (context, child) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              // LEVEL 1 STAGE
              if (stage1Built)
                Positioned(
                  left: widget.width * _plotCoords[1]!.dx,
                  top: widget.height * _plotCoords[1]!.dy,
                  child: FractionalTranslation(
                    translation: const Offset(-0.5, -0.5),
                    child: Image.asset(
                      'assets/images/house_stage1.png',
                      width: widget.width * 0.274,
                      height: widget.width * 0.274,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

              // LEVEL 2 STAGE (Plot 2 - Locked to left: 0.673, top: 0.628)
              if (stage2Built)
                Positioned(
                  left: widget.width * _plotCoords[2]!.dx,
                  top: widget.height * _plotCoords[2]!.dy,
                  child: FractionalTranslation(
                    translation: const Offset(-0.5, -0.5),
                    child: Image.asset(
                      'assets/images/house_stage2.png',
                      width: widget.width * 0.284,
                      height: widget.width * 0.284,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

              // LEVEL 3 STAGE (Plot 3 - Locked to left: 0.360, top: 0.438)
              if (stage3Built)
                Positioned(
                  left: widget.width * _plotCoords[3]!.dx,
                  top: widget.height * _plotCoords[3]!.dy,
                  child: FractionalTranslation(
                    translation: const Offset(-0.5, -0.5),
                    child: Image.asset(
                      'assets/images/house_stage3.png',
                      width: widget.width * 0.274,
                      height: widget.width * 0.274,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

              // LEVEL 4 STAGE (Plot 4 - Locked to left: 0.659, top: 0.277)
              if (stage4Built)
                Positioned(
                  left: widget.width * _plotCoords[4]!.dx,
                  top: widget.height * _plotCoords[4]!.dy,
                  child: FractionalTranslation(
                    translation: const Offset(-0.5, -0.5),
                    child: Image.asset(
                      'assets/images/house_stage4.png',
                      width: widget.width * 0.284,
                      height: widget.width * 0.284,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

              // LEVEL 5 STAGE
              if (stage5Built)
                Positioned(
                  left: widget.width * _plotCoords[5]!.dx,
                  top: widget.height * _plotCoords[5]!.dy,
                  child: FractionalTranslation(
                    translation: const Offset(-0.5, -0.5),
                    child: Image.asset(
                      'assets/images/house_stage5.png',
                      width: widget.width * 0.294,
                      height: widget.width * 0.294,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
