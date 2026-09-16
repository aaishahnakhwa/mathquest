import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/level_model.dart';
import '../providers/game_provider.dart';
import '../theme/colors.dart';

class FoundationBuilderScreen extends StatefulWidget {
  final LevelModel level;

  const FoundationBuilderScreen({super.key, required this.level});

  static String imageForProgress({
    required int progress,
    required int levelNumber,
    String worldId = 'world_1',
  }) {
    final visualStage = progress.clamp(0, GameProvider.levelHouseFinalStage);
    if (worldId == 'world_3' && levelNumber >= 11 && levelNumber <= 15) {
      if (visualStage == GameProvider.levelHouseFinalStage) {
        return 'assets/images/world3_level${levelNumber}_complete.png';
      }
      return 'assets/images/world3_level${levelNumber}_stage$visualStage.png';
    }
    if (worldId == 'world_2' && levelNumber >= 6 && levelNumber <= 10) {
      if (visualStage == GameProvider.levelHouseFinalStage) {
        return 'assets/images/world2_level${levelNumber}_complete.png';
      }
      return 'assets/images/world2_level${levelNumber}_stage$visualStage.png';
    }
    final buildingIndex = levelNumber.clamp(1, 5);
    if (visualStage == GameProvider.levelHouseFinalStage) {
      return 'assets/images/world1_level${buildingIndex}_complete.png';
    }
    return 'assets/images/world1_level${buildingIndex}_stage$visualStage.png';
  }

  @override
  State<FoundationBuilderScreen> createState() =>
      _FoundationBuilderScreenState();
}

class _FoundationBuilderScreenState extends State<FoundationBuilderScreen>
    with SingleTickerProviderStateMixin {
  int _logsLaid = 0;
  final int _targetLogs = GameProvider.levelHouseFinalStage;
  bool _isBuilding = false;
  bool _isCompleted = false;

  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
    );
  }

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final provider = Provider.of<GameProvider>(context, listen: false);
      final currentStage = provider.levelHouseStage(widget.level);
      _logsLaid = currentStage.clamp(0, _targetLogs);
      if (_logsLaid >= _targetLogs) {
        _isCompleted = true;
      }
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _layWoodLog(GameProvider provider) {
    if (_logsLaid >= _targetLogs ||
        provider.player.woodLogs <= 0 ||
        _isBuilding) {
      return;
    }

    setState(() {
      _isBuilding = true;
    });

    final didBuild = provider.advanceLevelHouseConstruction(widget.level);
    if (!didBuild) {
      setState(() {
        _isBuilding = false;
      });
      return;
    }

    _animController.forward(from: 0.0).then((_) {
      if (!mounted) return;
      setState(() {
        _logsLaid = provider.levelHouseStage(widget.level);
        _isBuilding = false;
        if (_logsLaid >= _targetLogs) {
          _isCompleted = true;
        }
      });
    });
  }

  int get _stageIndex => widget.level.worldId != 'world_1'
      ? widget.level.levelNumber
      : widget.level.levelNumber.clamp(1, 5);

  String get _buildingName => switch (_stageIndex) {
    1 => 'Cottage',
    2 => 'Smithy',
    3 => 'Village Shop',
    4 => 'Observatory',
    6 => 'Snow Cabin',
    7 => 'Snow Watermill',
    8 => 'Crystal Observatory',
    9 => 'Frost Guildhall',
    10 => 'Ice Castle',
    11 => 'Leafy Cottage',
    12 => 'Crystal Tree Sanctuary',
    13 => 'Forest Waterfall Observatory',
    14 => 'Forest Crystal Manor',
    15 => 'Celestial Sanctuary',
    _ => 'Castle',
  };

  String get _buildingIcon => switch (_stageIndex) {
    2 => '🛠️',
    3 => '🛍️',
    4 => '🔭',
    5 => '🏰',
    6 => '❄️',
    7 => '⚙️',
    8 => '💎',
    9 => '🏛️',
    10 => '🏰',
    11 => '🌿',
    12 => '💎',
    13 => '🔭',
    14 => '🏡',
    15 => '✨',
    _ => '🏡',
  };

  String _getStageImage() => FoundationBuilderScreen.imageForProgress(
    progress: _logsLaid,
    levelNumber: _stageIndex,
    worldId: widget.level.worldId,
  );

  String _getStageTitle() {
    if (_logsLaid <= 0) {
      if (_stageIndex == 13) {
        return 'Small forest hut — lay wood logs to expand it!';
      }
      return 'Empty plot — lay wood logs to build a new home!';
    } else if (_logsLaid == 1) {
      return 'Your new building is taking shape!';
    } else if (_logsLaid < _targetLogs) {
      return 'Building your new home ($_logsLaid/$_targetLogs logs)';
    } else {
      switch (_stageIndex) {
        case 1:
          return 'Level 1 Cottage Completed! 🪵';
        case 2:
          return 'Level 2 Smithy Completed! 🛠️';
        case 3:
          return 'Level 3 Village Shop Completed! 🛍️';
        case 4:
          return 'Level 4 Observatory Completed! 🔭';
        case 5:
          return 'Grand Castle Completed! 🏰';
        case 6:
          return 'Level 6 Snow Cabin Completed! ❄️';
        case 7:
          return 'Level 7 Snow Watermill Completed! ⚙️';
        case 8:
          return 'Level 8 Crystal Observatory Completed! 💎';
        case 9:
          return 'Level 9 Frost Guildhall Completed! 🏛️';
        case 10:
          return 'Level 10 Ice Castle Completed! 🏰';
        case 11:
          return 'Level 11 Leafy Cottage Completed! 🌿';
        case 12:
          return 'Level 12 Crystal Tree Sanctuary Completed! 💎';
        case 13:
          return 'Level 13 Forest Waterfall Observatory Completed! 🔭';
        case 14:
          return 'Level 14 Forest Crystal Manor Completed! 🏡';
        case 15:
          return 'Level 15 Celestial Sanctuary Completed! ✨';
        default:
          return 'Building Completed!';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, provider, child) {
        final player = provider.player;

        return Scaffold(
          backgroundColor: GameColors.background,
          appBar: AppBar(
            backgroundColor: GameColors.surfaceWarm,
            elevation: 2,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: GameColors.navyText,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Level ${widget.level.levelNumber} - $_buildingName Builder',
              style: const TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 18,
                color: GameColors.navyText,
              ),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Top Construction Info Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: GameColors.tealDark,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$_buildingIcon Level ${widget.level.levelNumber} $_buildingName',
                              style: const TextStyle(
                                fontFamily: 'Fredoka',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _getStageTitle(),
                              style: const TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Available Wood Logs Inventory Counter Pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/images/wood_log.png',
                              height: 22,
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
                ),

                // Main Illustrated House Construction View Area
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: GameColors.turquoise.withValues(alpha: 0.5),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: GameColors.navyText.withValues(alpha: 0.1),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(21),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Animated Switcher showing actual construction stage image
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 350),
                            switchInCurve: Curves.easeOut,
                            switchOutCurve: Curves.easeIn,
                            transitionBuilder: (child, animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: ScaleTransition(
                                  scale: Tween<double>(begin: 0.97, end: 1)
                                      .animate(
                                        CurvedAnimation(
                                          parent: animation,
                                          curve: Curves.easeOut,
                                        ),
                                      ),
                                  child: child,
                                ),
                              );
                            },
                            child: Padding(
                              key: ValueKey<String>(_getStageImage()),
                              padding: const EdgeInsets.all(16.0),
                              child: Image.asset(
                                _getStageImage(),
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.amber.shade100,
                                    child: Center(
                                      child: Text(
                                        '🏡 Stage $_logsLaid / $_targetLogs',
                                        style: const TextStyle(
                                          fontFamily: 'Fredoka',
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),

                          // Flying Wood Log placement particle effect
                          if (_isBuilding)
                            ScaleTransition(
                              scale: _scaleAnim,
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  shape: BoxShape.circle,
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 10,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Image.asset(
                                  'assets/images/wood_log.png',
                                  height: 64,
                                ),
                              ),
                            ),

                          // Bottom Floating Progress Pill Overlay
                          Positioned(
                            bottom: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: GameColors.surfaceWarm.withValues(
                                  alpha: 0.95,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: GameColors.sunnyYellow,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    '🪵 ',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  Text(
                                    'House Logs Placed: $_logsLaid / $_targetLogs',
                                    style: const TextStyle(
                                      fontFamily: 'Fredoka',
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: GameColors.navyText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Bottom Lay Wood Log Action Button & Return to Main Map Button
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      if (_isCompleted) ...[
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    '🎉 New building completed and added to the map!',
                                    style: TextStyle(fontFamily: 'Fredoka'),
                                  ),
                                  backgroundColor: GameColors.freshGreen,
                                ),
                              );
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: GameColors.freshGreen,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              elevation: 5,
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('🗺️ ', style: TextStyle(fontSize: 22)),
                                Flexible(
                                  child: Text(
                                    'BUILDING BUILT! RETURN TO MAIN MAP →',
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    style: TextStyle(
                                      fontFamily: 'Fredoka',
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ] else ...[
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: (player.woodLogs > 0 && !_isBuilding)
                                ? () => _layWoodLog(provider)
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: GameColors.turquoise,
                              disabledBackgroundColor: Colors.grey.shade400,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              elevation: player.woodLogs > 0 ? 5 : 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/wood_log.png',
                                  height: 24,
                                ),
                                const SizedBox(width: 10),
                                Flexible(
                                  child: Text(
                                    player.woodLogs > 0
                                        ? 'BUILD WITH WOOD LOG 🪵'
                                        : 'NEED MORE WOOD LOGS!',
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    style: const TextStyle(
                                      fontFamily: 'Fredoka',
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: GameColors.navyText,
                                width: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('🗺️ ', style: TextStyle(fontSize: 18)),
                                Flexible(
                                  child: Text(
                                    'RETURN TO MAIN MAP',
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    style: TextStyle(
                                      fontFamily: 'Fredoka',
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: GameColors.navyText,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
