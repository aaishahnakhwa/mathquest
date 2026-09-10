import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/game_provider.dart';

class VillageBuildingsOverlay extends StatelessWidget {
  final String worldId;
  final double width;
  final double height;

  const VillageBuildingsOverlay({
    super.key,
    required this.worldId,
    required this.width,
    required this.height,
  });

  // Calibrated Coordinates Map for all 5 Village Plots
  static const Map<int, Offset> _plotCoords = {
    1: Offset(0.336, 0.830), // Plot 1
    2: Offset(0.673, 0.628), // Locked Plot 2 Exact Position
    3: Offset(0.360, 0.438), // Locked Plot 3 Exact Position
    4: Offset(0.659, 0.277), // Locked Plot 4 Exact Position
    5: Offset(0.310, 0.175), // Plot 5
  };

  @override
  Widget build(BuildContext context) {
    if (worldId != 'world_1') {
      return const SizedBox.shrink();
    }

    final provider = Provider.of<GameProvider>(context);

    final world = provider.worlds.firstWhere((world) => world.id == worldId);
    final completedPlots = <int, bool>{
      for (var index = 0; index < world.levels.length; index++)
        index + 1: provider.isLevelHouseComplete(world.levels[index]),
    };

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // LEVEL 1 STAGE
          if (completedPlots[1] ?? false)
            Positioned(
              left: width * _plotCoords[1]!.dx,
              top: height * _plotCoords[1]!.dy,
              child: FractionalTranslation(
                translation: const Offset(-0.5, -0.5),
                child: Image.asset(
                  'assets/images/house_stage1.png',
                  width: width * 0.274,
                  height: width * 0.274,
                  fit: BoxFit.contain,
                ),
              ),
            ),

          // LEVEL 2 STAGE (Plot 2 - Locked to left: 0.673, top: 0.628)
          if (completedPlots[2] ?? false)
            Positioned(
              left: width * _plotCoords[2]!.dx,
              top: height * _plotCoords[2]!.dy,
              child: FractionalTranslation(
                translation: const Offset(-0.5, -0.5),
                child: Image.asset(
                  'assets/images/house_stage2.png',
                  width: width * 0.284,
                  height: width * 0.284,
                  fit: BoxFit.contain,
                ),
              ),
            ),

          // LEVEL 3 STAGE (Plot 3 - Locked to left: 0.360, top: 0.438)
          if (completedPlots[3] ?? false)
            Positioned(
              left: width * _plotCoords[3]!.dx,
              top: height * _plotCoords[3]!.dy,
              child: FractionalTranslation(
                translation: const Offset(-0.5, -0.5),
                child: Image.asset(
                  'assets/images/house_stage3.png',
                  width: width * 0.274,
                  height: width * 0.274,
                  fit: BoxFit.contain,
                ),
              ),
            ),

          // LEVEL 4 STAGE (Plot 4 - Locked to left: 0.659, top: 0.277)
          if (completedPlots[4] ?? false)
            Positioned(
              left: width * _plotCoords[4]!.dx,
              top: height * _plotCoords[4]!.dy,
              child: FractionalTranslation(
                translation: const Offset(-0.5, -0.5),
                child: Image.asset(
                  'assets/images/house_stage4.png',
                  width: width * 0.284,
                  height: width * 0.284,
                  fit: BoxFit.contain,
                ),
              ),
            ),

          // LEVEL 5 STAGE
          if (completedPlots[5] ?? false)
            Positioned(
              left: width * _plotCoords[5]!.dx,
              top: height * _plotCoords[5]!.dy,
              child: FractionalTranslation(
                translation: const Offset(-0.5, -0.5),
                child: Image.asset(
                  'assets/images/house_stage5.png',
                  width: width * 0.294,
                  height: width * 0.294,
                  fit: BoxFit.contain,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
