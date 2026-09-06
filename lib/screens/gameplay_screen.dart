import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/monster_model.dart';
import '../theme/colors.dart';
import '../widgets/game_button.dart';
import '../widgets/battle_arena_widget.dart';
import '../widgets/visual_math_helper.dart';
import '../widgets/concept_explanation_dialog.dart';
import '../widgets/in_game_audio_dialog.dart';
import 'level_complete_screen.dart';

class GameplayScreen extends StatefulWidget {
  const GameplayScreen({super.key});

  @override
  State<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends State<GameplayScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _bgAnimController;

  @override
  void initState() {
    super.initState();
    _bgAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, provider, child) {
        final level = provider.activeLevel;
        final question = provider.currentQuestion;
        final player = provider.player;

        if (level == null || question == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final totalQuestions = level.questions.length;
        final progressRatio =
            (provider.currentQuestionIndex + 1) / totalQuestions;
        final monster = MonsterModel.getForWorld(level.worldId);

        // Auto trigger Level Complete screen if finished
        if (provider.isLevelCompleted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const LevelCompleteScreen(),
              ),
            );
          });
        }

        // Out of Hearts Game Over Modal
        if (provider.levelHeartsLeft <= 0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showOutOfHeartsDialog(context, provider);
          });
        }

        return Scaffold(
          body: Stack(
            children: [
              // 1. ISOLATED GPU REPAINT BOUNDARY FOR BACKGROUND GRADIENT & CLOUDS
              RepaintBoundary(
                child: AnimatedBuilder(
                  animation: _bgAnimController,
                  builder: (context, child) {
                    final animVal = _bgAnimController.value;
                    return Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFFBAE6FD), // Sky Blue Top
                            Color(0xFFE0F2FE), // Soft Cyan Horizon
                            Color(0xFFDCFCE7), // Fresh Meadow Grass
                            Color(0xFFF0FDF4), // Warm Base
                          ],
                          stops: [0.0, 0.35, 0.75, 1.0],
                        ),
                      ),
                      child: CustomPaint(
                        size: Size.infinite,
                        painter: _GameplayBgPainter(animValue: animVal),
                      ),
                    );
                  },
                ),
              ),

              // 2. MAIN SCROLLABLE GAMEPLAY CONTENT
              SafeArea(
                child: Column(
                  children: [
                    // Top Gamified HUD Header: Back Button, Gems Counter, Progress Pill & Hearts
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        boxShadow: [
                          BoxShadow(
                            color: GameColors.navyText.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                        border: const Border(
                          bottom: BorderSide(color: GameColors.cardBorder, width: 2),
                        ),
                      ),
                      child: Row(
                        children: [
                          // 3D Pixel Back Button (<)
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFF38BDF8), width: 2.5),
                                boxShadow: const [
                                  BoxShadow(color: Color(0xFF0284C7), offset: Offset(0, 3)),
                                ],
                              ),
                              child: const Center(
                                child: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF0284C7)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Live Gems Balance Counter
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: GameColors.gemPurple, width: 2.5),
                              boxShadow: const [
                                BoxShadow(color: GameColors.jellyPurpleDark, offset: Offset(0, 2.5)),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('💎 ', style: TextStyle(fontSize: 13)),
                                Text(
                                  '${player.gems}',
                                  style: const TextStyle(
                                    fontFamily: 'Fredoka',
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: GameColors.gemPurple,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Progress Bar & Level Title Pill
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.grey.shade300, width: 1.5),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          level.title,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontFamily: 'Fredoka',
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: GameColors.navyText,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${provider.currentQuestionIndex + 1}/$totalQuestions',
                                        style: const TextStyle(
                                          fontFamily: 'Fredoka',
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: GameColors.skyBlueDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Stack(
                                      children: [
                                        Container(height: 7, color: Colors.grey.shade300),
                                        FractionallySizedBox(
                                          widthFactor: progressRatio,
                                          child: Container(
                                            height: 7,
                                            decoration: const BoxDecoration(
                                              gradient: GameColors.greenGradient,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // 3D Pixel Hearts Display ❤️
                          Row(
                            children: List.generate(3, (index) {
                              final hasHeart = index < provider.levelHeartsLeft;
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 1.0),
                                child: Text(
                                  hasHeart ? '❤️' : '🖤',
                                  style: const TextStyle(fontSize: 15),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(width: 6),

                          // Quick In-Game Volume Adjustment Button 🎵
                          GestureDetector(
                            onTap: () => InGameAudioDialog.show(context),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: const Color(0xFF6C5CE7).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFF6C5CE7).withValues(alpha: 0.5),
                                  width: 1.5,
                                ),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.volume_up_rounded,
                                  size: 18,
                                  color: Color(0xFF6C5CE7),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Main Gameplay Body
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Column(
                          children: [
                            // 2D MATH BATTLE ARENA (HERO VS MONSTER FOE)
                            RepaintBoundary(
                              child: BattleArenaWidget(
                                player: player,
                                monster: monster,
                                isSubmitted: provider.isAnswerSubmitted,
                                isCorrect: provider.isCorrectAnswer,
                                heartsLeft: provider.levelHeartsLeft,
                                hitCount: provider.levelCorrectCount,
                                totalQuestions: totalQuestions,
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Topic Badge & Hint Action Button (Glossy Pills)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Glossy Sky Blue Topic Pill
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: const Color(0xFF0284C7), width: 2),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0xFF0369A1),
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Stack(
                                      children: [
                                        Positioned.fill(
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [
                                                  Color(0xFFE0F2FE),
                                                  Color(0xFFBAE6FD),
                                                  Color(0xFF7DD3FC),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 0,
                                          left: 0,
                                          right: 0,
                                          height: 12,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [
                                                  Colors.white.withValues(alpha: 0.75),
                                                  Colors.white.withValues(alpha: 0.0),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          child: Row(
                                            children: [
                                              const Text('⚔️ ', style: TextStyle(fontSize: 12)),
                                              Text(
                                                question.topic,
                                                style: const TextStyle(
                                                  fontFamily: 'Fredoka',
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF0369A1),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Glossy Purple Hint Button
                                GestureDetector(
                                  onTap: () => _handleHintTap(context, provider),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: const Color(0xFF9333EA), width: 2),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color(0xFF7E22CE),
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: Stack(
                                        children: [
                                          Positioned.fill(
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                  colors: [
                                                    Color(0xFFF3E8FF),
                                                    Color(0xFFE9D5FF),
                                                    Color(0xFFD8B4FE),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: 0,
                                            left: 0,
                                            right: 0,
                                            height: 12,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                  colors: [
                                                    Colors.white.withValues(alpha: 0.75),
                                                    Colors.white.withValues(alpha: 0.0),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            child: const Row(
                                              children: [
                                                Text('💡 Hint ',
                                                    style: TextStyle(
                                                      fontFamily: 'Fredoka',
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold,
                                                      color: Color(0xFF6B21A8),
                                                    )),
                                                Text('💎 3',
                                                    style: TextStyle(
                                                      fontFamily: 'Fredoka',
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold,
                                                      color: Color(0xFF6B21A8),
                                                    )),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // QUESTION CARD & VISUAL MATH HELPER (GLOSSY GOLDEN/CREAM 3D CARD)
                            RepaintBoundary(
                              child: Container(
                                width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(color: const Color(0xFFF59E0B), width: 3.5),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0xFFD97706),
                                    offset: Offset(0, 5),
                                  ),
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 10,
                                    offset: Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(18.5),
                                child: Stack(
                                  children: [
                                    // Glossy Warm Yellow Gradient Background
                                    Positioned.fill(
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Color(0xFFFFFDF5),
                                              Color(0xFFFFFBEB),
                                              Color(0xFFFEF3C7),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Top White Glass Highlight Sheen
                                    Positioned(
                                      top: 0,
                                      left: 0,
                                      right: 0,
                                      height: 35,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.white.withValues(alpha: 0.8),
                                              Colors.white.withValues(alpha: 0.0),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Card Content
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        children: [
                                          Text(
                                            question.questionText,
                                            style: const TextStyle(
                                              fontFamily: 'Fredoka',
                                              fontSize: 26,
                                              fontWeight: FontWeight.bold,
                                              color: GameColors.navyText,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 12),

                                          // VISUAL MATH HELPER (BASE-10 3D BLOCKS)
                                          VisualMathHelper(
                                            questionText: question.questionText,
                                            topic: question.topic,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            ),
                            const SizedBox(height: 14),

                            // 2X2 GAMIFIED VIBRANT GLOSSY 3D ANSWER CHOICE GRID
                            RepaintBoundary(
                              child: GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: question.options.length,
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 2.2,
                                  mainAxisSpacing: 10,
                                  crossAxisSpacing: 10,
                                ),
                              itemBuilder: (context, index) {
                                final optionText = question.options[index];
                                final isSelected = provider.selectedAnswerIndex == index;
                                final isSubmitted = provider.isAnswerSubmitted;
                                final isCorrect = index == question.correctAnswerIndex;

                                // Bright vibrant option gradient themes (Blue, Green, Purple, Red)
                                final optionGradients = [
                                  // A - Blue Glossy
                                  const [Color(0xFFEFF6FF), Color(0xFFDBEAFE), Color(0xFFBFDBFE)],
                                  // B - Green Glossy
                                  const [Color(0xFFF0FDF4), Color(0xFFDCFCE7), Color(0xFFBBF7D0)],
                                  // C - Purple Glossy
                                  const [Color(0xFFFAF5FF), Color(0xFFF3E8FF), Color(0xFFE9D5FF)],
                                  // D - Coral Red Glossy
                                  const [Color(0xFFFFF1F2), Color(0xFFFFE4E6), Color(0xFFFECDD3)],
                                ];
                                final optionBorders = [
                                  const Color(0xFF3B82F6), // Blue
                                  const Color(0xFF22C55E), // Green
                                  const Color(0xFFA855F7), // Purple
                                  const Color(0xFFF43F5E), // Red
                                ];
                                final optionShadows = [
                                  const Color(0xFF1D4ED8),
                                  const Color(0xFF15803D),
                                  const Color(0xFF7E22CE),
                                  const Color(0xFFBE123C),
                                ];
                                final badgeColors = [
                                  const Color(0xFF2563EB),
                                  const Color(0xFF16A34A),
                                  const Color(0xFF9333EA),
                                  const Color(0xFFE11D48),
                                ];

                                List<Color> cardGradient = optionGradients[index % 4];
                                Color cardBorder = optionBorders[index % 4];
                                Color shadowColor = optionShadows[index % 4];
                                Color badgeColor = badgeColors[index % 4];
                                Color textColor = GameColors.navyText;

                                if (isSubmitted) {
                                  if (isCorrect) {
                                    cardGradient = const [Color(0xFF4ADE80), Color(0xFF22C55E), Color(0xFF16A34A)];
                                    cardBorder = const Color(0xFF15803D);
                                    shadowColor = const Color(0xFF14532D);
                                    textColor = Colors.white;
                                  } else if (isSelected) {
                                    cardGradient = const [Color(0xFFFB7185), Color(0xFFF43F5E), Color(0xFFE11D48)];
                                    cardBorder = const Color(0xFFBE123C);
                                    shadowColor = const Color(0xFF881337);
                                    textColor = Colors.white;
                                  }
                                } else if (isSelected) {
                                  cardGradient = const [Color(0xFF38BDF8), Color(0xFF0284C7), Color(0xFF0369A1)];
                                  cardBorder = const Color(0xFF075985);
                                  shadowColor = const Color(0xFF0C4A6E);
                                  textColor = Colors.white;
                                }

                                return GestureDetector(
                                  onTap: () => provider.selectAnswer(index),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(color: cardBorder, width: 2.5),
                                      boxShadow: [
                                        BoxShadow(
                                          color: shadowColor.withValues(alpha: 0.6),
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(15.5),
                                      child: Stack(
                                        children: [
                                          // Card Glossy Gradient Background
                                          Positioned.fill(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                  colors: cardGradient,
                                                ),
                                              ),
                                            ),
                                          ),
                                          // Top White Glass Highlight Sheen
                                          Positioned(
                                            top: 0,
                                            left: 0,
                                            right: 0,
                                            height: 18,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                  colors: [
                                                    Colors.white.withValues(alpha: isSelected || (isSubmitted && (isCorrect || isSelected)) ? 0.45 : 0.75),
                                                    Colors.white.withValues(alpha: 0.0),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          // Card Body
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                            child: Row(
                                              children: [
                                                // 3D Letter Badge
                                                Container(
                                                  width: 32,
                                                  height: 32,
                                                  decoration: BoxDecoration(
                                                    color: (isSelected || (isSubmitted && (isCorrect || isSelected))) ? Colors.white.withValues(alpha: 0.3) : badgeColor,
                                                    borderRadius: BorderRadius.circular(9),
                                                    boxShadow: const [
                                                      BoxShadow(
                                                        color: Colors.black26,
                                                        offset: Offset(0, 2),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      String.fromCharCode(65 + index),
                                                      style: const TextStyle(
                                                        fontFamily: 'Fredoka',
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Text(
                                                    optionText,
                                                    style: TextStyle(
                                                      fontFamily: 'Fredoka',
                                                      fontSize: 22,
                                                      fontWeight: FontWeight.bold,
                                                      color: textColor,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          // Correct Checkmark Badge (Top-Right)
                                          if (isSubmitted && isCorrect)
                                            Positioned(
                                              top: 4,
                                              right: 4,
                                              child: Container(
                                                padding: const EdgeInsets.all(3),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFF14532D),
                                                  borderRadius: BorderRadius.circular(6),
                                                  boxShadow: const [
                                                    BoxShadow(color: Colors.black26, offset: Offset(0, 1.5)),
                                                  ],
                                                ),
                                                child: const Icon(
                                                  Icons.check_rounded,
                                                  size: 14,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                               },
                             ),
                             ),
                             const SizedBox(height: 16),

                            // BOTTOM ACTION BUTTON
                            GameButton(
                              text: provider.isAnswerSubmitted
                                  ? 'ATTACKING... ⚔️'
                                  : 'ATTACK & SUBMIT ⚔️',
                              backgroundColor: GameColors.sunnyYellow,
                              shadowColor: GameColors.yellowDark,
                              textColor: GameColors.navyText,
                              onPressed: (!provider.isAnswerSubmitted && provider.selectedAnswerIndex != null)
                                  ? () => _handleSubmitAnswer(provider)
                                  : null,
                              height: 52,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleSubmitAnswer(GameProvider provider) {
    if (provider.selectedAnswerIndex == null || provider.isAnswerSubmitted) {
      return;
    }

    final currentQIndex = provider.currentQuestionIndex;
    provider.submitAnswer();

    // Automatically transition to next question after attack animation completes
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;

      if (provider.isAnswerSubmitted &&
          provider.currentQuestionIndex == currentQIndex) {
        if (provider.levelHeartsLeft <= 0 || provider.isLevelCompleted) {
          return;
        }

        if (provider.isCorrectAnswer) {
          provider.nextQuestion();
        } else {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => ConceptExplanationDialog(
              question: provider.currentQuestion!,
              onContinue: () {
                Navigator.pop(context);
                provider.nextQuestion();
              },
            ),
          );
        }
      }
    });
  }

  void _handleHintTap(BuildContext context, GameProvider provider) {
    final currentGems = provider.player.gems;

    if (currentGems < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('💎 Need 3 Gems for a hint! Solve levels to earn more.'),
          backgroundColor: GameColors.coralDark,
        ),
      );
      return;
    }

    final isExhausting = (currentGems - 3) == 0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: GameColors.surfaceWarm,
        title: Row(
          children: [
            Text(isExhausting ? '⚠️ ' : '💎 ', style: const TextStyle(fontSize: 22)),
            Text(
              isExhausting ? 'GEM EXHAUSTION WARNING' : 'CONFIRM HINT',
              style: TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isExhausting ? GameColors.coralDark : GameColors.navyText,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isExhausting
                  ? 'Warning: Unlocking this hint will spend your final 3 Gems! You will have 0 Gems remaining.'
                  : 'Using this hint will spend 3 Gems. You will have ${currentGems - 3} Gems remaining.',
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: GameColors.navyTextSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isExhausting
                    ? GameColors.coralLight
                    : GameColors.gemPurple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isExhausting ? GameColors.coral : GameColors.gemPurple,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  const Text('💎 ', style: TextStyle(fontSize: 16)),
                  Text(
                    'Cost: 3 Gems  |  Balance After: ${currentGems - 3}',
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isExhausting ? GameColors.coralDark : GameColors.gemPurple,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL',
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontWeight: FontWeight.bold,
                  color: GameColors.navyTextSecondary,
                )),
          ),
          GameButton(
            text: 'CONFIRM (💎 3)',
            backgroundColor: isExhausting ? GameColors.coral : GameColors.gemPurple,
            shadowColor: isExhausting ? GameColors.coralDark : GameColors.gemPurple,
            textColor: Colors.white,
            height: 40,
            fontSize: 12,
            onPressed: () {
              Navigator.pop(context);
              _executeHintUse(context, provider);
            },
          ),
        ],
      ),
    );
  }

  void _executeHintUse(BuildContext context, GameProvider provider) {
    final success = provider.useHint();
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('💎 Spent 3 Gems! ${provider.player.gems} Gems remaining.'),
          backgroundColor: GameColors.gemPurple,
          duration: const Duration(seconds: 2),
        ),
      );

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Row(
            children: [
              Text('💡 ', style: TextStyle(fontSize: 22)),
              Text('QUESTION HINT',
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  )),
            ],
          ),
          content: Text(
            provider.currentQuestion?.hintText ?? 'Break down numbers by tens!',
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('GOT IT',
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontWeight: FontWeight.bold,
                  )),
            ),
          ],
        ),
      );
    }
  }

  void _showOutOfHeartsDialog(BuildContext context, GameProvider provider) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Text('💔 ', style: TextStyle(fontSize: 24)),
            Text('OUT OF HEARTS!',
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: GameColors.coralDark,
                )),
          ],
        ),
        content: const Text(
          'You ran out of hearts for this level! Would you like to revive with 5 Gems or retry?',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (provider.activeLevel != null) {
                provider.startLevel(provider.activeLevel!);
              }
            },
            child: const Text('RETRY LEVEL',
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontWeight: FontWeight.bold,
                  color: GameColors.navyTextSecondary,
                )),
          ),
          GameButton(
            text: 'REVIVE (💎 5)',
            backgroundColor: GameColors.freshGreen,
            shadowColor: GameColors.freshGreenDark,
            textColor: Colors.white,
            height: 42,
            fontSize: 13,
            onPressed: () {
              if (provider.reviveLevelWithGems()) {
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('💎 Need 5 Gems to revive!'),
                    backgroundColor: GameColors.coralDark,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

// Custom Painter for Gameplay Screen Background (Clouds & Meadow Hills)
class _GameplayBgPainter extends CustomPainter {
  final double animValue;
  _GameplayBgPainter({required this.animValue});

  @override
  void paint(Canvas canvas, Size size) {
    final cloudPaint = Paint()..color = Colors.white.withValues(alpha: 0.6);

    // Floating Clouds ☁️
    final c1 = Offset(size.width * 0.15 + (animValue * 15), size.height * 0.08);
    canvas.drawCircle(c1, 28, cloudPaint);
    canvas.drawCircle(Offset(c1.dx - 18, c1.dy + 6), 20, cloudPaint);
    canvas.drawCircle(Offset(c1.dx + 18, c1.dy + 6), 20, cloudPaint);

    final c2 = Offset(size.width * 0.85 - (animValue * 15), size.height * 0.14);
    canvas.drawCircle(c2, 22, cloudPaint);
    canvas.drawCircle(Offset(c2.dx - 14, c2.dy + 4), 16, cloudPaint);
    canvas.drawCircle(Offset(c2.dx + 14, c2.dy + 4), 16, cloudPaint);

    // Distant Rolling Meadow Hills
    final hillPath = Path()
      ..moveTo(0, size.height * 0.88)
      ..quadraticBezierTo(size.width * 0.35, size.height * 0.82, size.width * 0.7, size.height * 0.89)
      ..quadraticBezierTo(size.width * 0.9, size.height * 0.92, size.width, size.height * 0.86)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      hillPath,
      Paint()..color = const Color(0xFF86EFAC).withValues(alpha: 0.4),
    );
  }

  @override
  bool shouldRepaint(covariant _GameplayBgPainter oldDelegate) =>
      oldDelegate.animValue != animValue;
}
