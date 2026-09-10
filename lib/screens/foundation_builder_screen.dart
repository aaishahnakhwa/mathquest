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
  }) {
    final visualStage = progress.clamp(0, GameProvider.levelHouseFinalStage);
    if (levelNumber == 3) {
      switch (visualStage) {
        case 0:
          return 'assets/images/house_stage2.png';
        case 1:
          return 'assets/images/level3_construction_1.png';
        case 2:
          return 'assets/images/level3_construction_2.png';
        case 3:
          return 'assets/images/level3_construction_3.png';
        case GameProvider.levelHouseFinalStage:
        default:
          return 'assets/images/house_stage3.png';
      }
    }

    if (levelNumber == 4) {
      switch (visualStage) {
        case 0:
          return 'assets/images/house_stage3.png';
        case 1:
          return 'assets/images/level4_construction_1.png';
        case 2:
          return 'assets/images/level4_construction_2.png';
        case 3:
          return 'assets/images/level4_construction_3.png';
        case GameProvider.levelHouseFinalStage:
        default:
          return 'assets/images/house_stage4.png';
      }
    }

    if (levelNumber == 5) {
      switch (visualStage) {
        case 0:
          return 'assets/images/house_stage4.png';
        case 1:
          return 'assets/images/level5_construction_1.png';
        case 2:
          return 'assets/images/level5_construction_2.png';
        case 3:
          return 'assets/images/level5_construction_3.png';
        case GameProvider.levelHouseFinalStage:
        default:
          return 'assets/images/house_stage5.png';
      }
    }

    switch (visualStage) {
      case 0:
        return 'assets/images/const_stage1.png';
      case 1:
        return 'assets/images/construction_stage_1.png';
      case 2:
        return 'assets/images/construction_stage_2.png';
      case 3:
        return 'assets/images/construction_stage_3.png';
      case GameProvider.levelHouseFinalStage:
      default:
        final finalBuildingIndex = levelNumber.clamp(1, 5);
        return 'assets/images/house_stage$finalBuildingIndex.png';
    }
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

  int get _stageIndex => widget.level.levelNumber.clamp(1, 5);

  String _getStageImage() => FoundationBuilderScreen.imageForProgress(
    progress: _logsLaid,
    levelNumber: _stageIndex,
  );

  String _getStageTitle() {
    if (_logsLaid <= 0) {
      return 'Stage 1/4: Empty Foundation — Lay Wood Logs to Build!';
    } else if (_logsLaid == 1) {
      return 'Stage 2/4: Stone Foundation Laid!';
    } else if (_logsLaid < _targetLogs) {
      return 'Stage 3/4: Timber Framework Erected! ($_logsLaid/$_targetLogs Logs)';
    } else {
      switch (_stageIndex) {
        case 1:
          return 'Stage 4/4: Level 1 Cottage Completed! 🪵';
        case 2:
          return 'Stage 4/4: Level 2 House Completed! 🪵';
        case 3:
          return 'Stage 4/4: Level 3 Timber House Completed! 🪵';
        case 4:
          return 'Stage 4/4: Level 4 Villa Completed! 🪵';
        case 5:
        default:
          return 'Stage 4/4: Grand Fantasy House Completed! 🎉';
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
              'Level ${widget.level.levelNumber} - House Builder',
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '🏡 ${widget.level.title} Cottage',
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
                                    '🎉 House stage completed & saved to map!',
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
                                Text(
                                  'STAGE BUILT! RETURN TO MAIN MAP →',
                                  style: TextStyle(
                                    fontFamily: 'Fredoka',
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
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
                                Text(
                                  player.woodLogs > 0
                                      ? 'BUILD WITH WOOD LOG 🪵'
                                      : 'NEED MORE WOOD LOGS!',
                                  style: const TextStyle(
                                    fontFamily: 'Fredoka',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
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
                                Text(
                                  'RETURN TO MAIN MAP',
                                  style: TextStyle(
                                    fontFamily: 'Fredoka',
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: GameColors.navyText,
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
