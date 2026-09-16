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
    1: Offset(0.336, 0.812), // Plot 1: align cottage footprint to plot stones
    2: Offset(0.673, 0.610), // Plot 2: align smithy footprint to plot stones
    3: Offset(0.370, 0.431), // Plot 3: align shop footprint to plot stones
    4: Offset(0.659, 0.260), // Plot 4: align observatory to plot stones
    5: Offset(0.300, 0.168), // Plot 5: align castle footprint to plot stones
  };

  static const Offset _world2FirstPlot = Offset(0.680, 0.723);
  static const Offset _world2SecondPlot = Offset(0.362, 0.530);
  static const Offset _world2ThirdPlot = Offset(0.370, 0.227);
  static const Offset _world2FourthPlot = Offset(0.745, 0.100);
  static const Offset _world2FifthPlot = Offset(0.395, 0.083);
  static const Offset _world3FirstPlot = Offset(0.695, 0.770);
  static const Offset _world3SecondPlot = Offset(0.360, 0.608);
  static const Offset _world3ThirdPlot = Offset(0.695, 0.442);
  static const Offset _world3FourthPlot = Offset(0.365, 0.247);
  static const Offset _world3FifthPlot = Offset(0.675, 0.084);

  @override
  Widget build(BuildContext context) {
    if (worldId != 'world_1' && worldId != 'world_2' && worldId != 'world_3') {
      return const SizedBox.shrink();
    }

    final provider = Provider.of<GameProvider>(context);

    final world = provider.worlds.firstWhere((world) => world.id == worldId);
    if (worldId == 'world_3') {
      final level11Complete = provider.isLevelHouseComplete(world.levels[0]);
      final level12Complete = provider.isLevelHouseComplete(world.levels[1]);
      final level13Complete = provider.isLevelHouseComplete(world.levels[2]);
      final level14Complete = provider.isLevelHouseComplete(world.levels[3]);
      final level15Complete = provider.isLevelHouseComplete(world.levels[4]);
      if (!level11Complete &&
          !level12Complete &&
          !level13Complete &&
          !level14Complete &&
          !level15Complete) {
        return const SizedBox.shrink();
      }
      return SizedBox(
        width: width,
        height: height,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            if (level11Complete)
              Positioned(
                left: width * _world3FirstPlot.dx,
                top: height * _world3FirstPlot.dy,
                child: FractionalTranslation(
                  translation: const Offset(-0.5, -0.5),
                  child: Image.asset(
                    'assets/images/world3_level11_complete.png',
                    width: width * 0.320,
                    height: width * 0.320,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
            if (level12Complete)
              Positioned(
                left: width * _world3SecondPlot.dx,
                top: height * _world3SecondPlot.dy,
                child: FractionalTranslation(
                  translation: const Offset(-0.5, -0.5),
                  child: Image.asset(
                    'assets/images/world3_level12_complete.png',
                    width: width * 0.320,
                    height: width * 0.320,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
            if (level13Complete)
              Positioned(
                left: width * _world3ThirdPlot.dx,
                top: height * _world3ThirdPlot.dy,
                child: FractionalTranslation(
                  translation: const Offset(-0.5, -0.5),
                  child: Image.asset(
                    'assets/images/world3_level13_complete.png',
                    width: width * 0.320,
                    height: width * 0.320,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
            if (level14Complete)
              Positioned(
                left: width * _world3FourthPlot.dx,
                top: height * _world3FourthPlot.dy,
                child: FractionalTranslation(
                  translation: const Offset(-0.5, -0.5),
                  child: Image.asset(
                    'assets/images/world3_level14_complete.png',
                    width: width * 0.320,
                    height: width * 0.320,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
            if (level15Complete)
              Positioned(
                left: width * _world3FifthPlot.dx,
                top: height * _world3FifthPlot.dy,
                child: FractionalTranslation(
                  translation: const Offset(-0.5, -0.5),
                  child: Image.asset(
                    'assets/images/world3_level15_complete.png',
                    width: width * 0.300,
                    height: width * 0.300,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
          ],
        ),
      );
    }
    if (worldId == 'world_2') {
      final level6Complete = provider.isLevelHouseComplete(world.levels[0]);
      final level7Complete = provider.isLevelHouseComplete(world.levels[1]);
      final level8Complete = provider.isLevelHouseComplete(world.levels[2]);
      final level9Complete = provider.isLevelHouseComplete(world.levels[3]);
      final level10Complete = provider.isLevelHouseComplete(world.levels[4]);
      if (!level6Complete &&
          !level7Complete &&
          !level8Complete &&
          !level9Complete &&
          !level10Complete) {
        return const SizedBox.shrink();
      }
      return SizedBox(
        width: width,
        height: height,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            if (level6Complete)
              Positioned(
                left: width * _world2FirstPlot.dx,
                top: height * _world2FirstPlot.dy,
                child: FractionalTranslation(
                  translation: const Offset(-0.5, -0.5),
                  child: Image.asset(
                    'assets/images/world2_level6_complete.png',
                    width: width * 0.320,
                    height: width * 0.320,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
            if (level7Complete)
              Positioned(
                left: width * _world2SecondPlot.dx,
                top: height * _world2SecondPlot.dy,
                child: FractionalTranslation(
                  translation: const Offset(-0.5, -0.5),
                  child: Image.asset(
                    'assets/images/world2_level7_complete.png',
                    width: width * 0.320,
                    height: width * 0.320,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
            if (level8Complete)
              Positioned(
                left: width * _world2ThirdPlot.dx,
                top: height * _world2ThirdPlot.dy,
                child: FractionalTranslation(
                  translation: const Offset(-0.5, -0.5),
                  child: Image.asset(
                    'assets/images/world2_level8_complete.png',
                    width: width * 0.320,
                    height: width * 0.320,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
            if (level9Complete)
              Positioned(
                left: width * _world2FourthPlot.dx,
                top: height * _world2FourthPlot.dy,
                child: FractionalTranslation(
                  translation: const Offset(-0.5, -0.5),
                  child: Image.asset(
                    'assets/images/world2_level9_complete.png',
                    width: width * 0.300,
                    height: width * 0.300,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
            if (level10Complete)
              Positioned(
                left: width * _world2FifthPlot.dx,
                top: height * _world2FifthPlot.dy,
                child: FractionalTranslation(
                  translation: const Offset(-0.5, -0.5),
                  child: Image.asset(
                    'assets/images/world2_level10_complete.png',
                    width: width * 0.280,
                    height: width * 0.280,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
          ],
        ),
      );
    }

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
          // Each completed level adds a separate building to its own plot.
          if (completedPlots[1] ?? false)
            Positioned(
              left: width * _plotCoords[1]!.dx,
              top: height * _plotCoords[1]!.dy,
              child: FractionalTranslation(
                translation: const Offset(-0.5, -0.5),
                child: Image.asset(
                  'assets/images/world1_level1_complete.png',
                  width: width * 0.360,
                  height: width * 0.360,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),

          // Level 2 smithy on its own plot.
          if (completedPlots[2] ?? false)
            Positioned(
              left: width * _plotCoords[2]!.dx,
              top: height * _plotCoords[2]!.dy,
              child: FractionalTranslation(
                translation: const Offset(-0.5, -0.5),
                child: Image.asset(
                  'assets/images/world1_level2_complete.png',
                  width: width * 0.360,
                  height: width * 0.360,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),

          // Level 3 village shop on its own plot.
          if (completedPlots[3] ?? false)
            Positioned(
              left: width * _plotCoords[3]!.dx,
              top: height * _plotCoords[3]!.dy,
              child: FractionalTranslation(
                translation: const Offset(-0.5, -0.5),
                child: Image.asset(
                  'assets/images/world1_level3_complete.png',
                  width: width * 0.360,
                  height: width * 0.360,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),

          // Level 4 observatory on its own plot.
          if (completedPlots[4] ?? false)
            Positioned(
              left: width * _plotCoords[4]!.dx,
              top: height * _plotCoords[4]!.dy,
              child: FractionalTranslation(
                translation: const Offset(-0.5, -0.5),
                child: Image.asset(
                  'assets/images/world1_level4_complete.png',
                  width: width * 0.360,
                  height: width * 0.360,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),

          // Level 5 castle completes the world village.
          if (completedPlots[5] ?? false)
            Positioned(
              left: width * _plotCoords[5]!.dx,
              top: height * _plotCoords[5]!.dy,
              child: FractionalTranslation(
                translation: const Offset(-0.5, -0.5),
                child: Image.asset(
                  'assets/images/world1_level5_complete.png',
                  width: width * 0.340,
                  height: width * 0.340,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
