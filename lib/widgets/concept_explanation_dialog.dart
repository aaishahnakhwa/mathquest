import 'package:flutter/material.dart';

import '../models/question_model.dart';
import '../theme/colors.dart';
import 'game_button.dart';

class ConceptExplanationDialog extends StatelessWidget {
  final QuestionModel question;
  final VoidCallback onContinue;

  const ConceptExplanationDialog({
    super.key,
    required this.question,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFDF5),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFFF59E0B), width: 4),
          boxShadow: [
            const BoxShadow(color: Color(0xFFD97706), offset: Offset(0, 7)),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Mascot & Encouragement Banner
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: GameColors.coralLight,
                      border: Border.all(color: GameColors.coral, width: 2.5),
                      boxShadow: const [
                        BoxShadow(
                          color: GameColors.coralDark,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text('🦉', style: TextStyle(fontSize: 28)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'NOT QUITE!',
                          style: TextStyle(
                            fontFamily: 'Fredoka',
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: GameColors.coralDark,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          'Let\'s break down the math together with Professor Owl!',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 12,
                            color: GameColors.navyTextSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                height: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.grey.shade200,
                      GameColors.cardBorder,
                      Colors.grey.shade200,
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // 1. Glossy Question Statement Card (Sky Blue Theme)
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF0284C7),
                    width: 2.5,
                  ),
                  boxShadow: const [
                    BoxShadow(color: Color(0xFF0369A1), offset: Offset(0, 3.5)),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(17.5),
                  child: Stack(
                    children: [
                      // Glossy Blue Gradient Background
                      Positioned.fill(
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0xFFF0F9FF),
                                Color(0xFFE0F2FE),
                                Color(0xFFBAE6FD),
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
                        height: 24,
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
                      // Card Content
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0284C7),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'QUESTION',
                                style: TextStyle(
                                  fontFamily: 'Fredoka',
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              question.questionText,
                              style: const TextStyle(
                                fontFamily: 'Fredoka',
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: GameColors.navyText,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // 2. Glossy Concept Breakdown Card (Warm Golden Honey / Sunset Amber Theme)
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: const Color(0xFFF59E0B),
                    width: 2.5,
                  ),
                  boxShadow: const [
                    BoxShadow(color: Color(0xFFD97706), offset: Offset(0, 4)),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(19.5),
                  child: Stack(
                    children: [
                      // Glossy Amber Honey Gradient Background
                      Positioned.fill(
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0xFFFFFDF0),
                                Color(0xFFFEF3C7),
                                Color(0xFFFDE68A),
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
                        height: 32,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withValues(alpha: 0.85),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  '💡',
                                  style: TextStyle(fontSize: 18),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD97706),
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0xFFB45309),
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Text(
                                    'CONCEPT BREAKDOWN',
                                    style: TextStyle(
                                      fontFamily: 'Fredoka',
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 0.6,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            ...question.explanationSteps.map(
                              (step) => Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      '👉 ',
                                      style: TextStyle(fontSize: 15),
                                    ),
                                    Expanded(
                                      child: Text(
                                        step,
                                        style: const TextStyle(
                                          fontFamily: 'Fredoka',
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF78350F),
                                          height: 1.3,
                                        ),
                                      ),
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
                ),
              ),
              const SizedBox(height: 14),

              // 3. Glossy Correct Answer Banner (Royal Violet Purple Theme)
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFF7E22CE),
                    width: 2.5,
                  ),
                  boxShadow: const [
                    BoxShadow(color: Color(0xFF581C87), offset: Offset(0, 4)),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15.5),
                  child: Stack(
                    children: [
                      // Glossy Royal Purple Gradient
                      Positioned.fill(
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0xFFC084FC),
                                Color(0xFF9333EA),
                                Color(0xFF7E22CE),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Top White Glass Reflection Sheen
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 20,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withValues(alpha: 0.65),
                                Colors.white.withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Banner Text Content
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              '✅ Correct Answer: ',
                              style: TextStyle(
                                fontFamily: 'Fredoka',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              question.options[question.correctAnswerIndex],
                              style: const TextStyle(
                                fontFamily: 'Fredoka',
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFEF08A),
                                shadows: [
                                  Shadow(
                                    color: Colors.black38,
                                    offset: Offset(0, 1.5),
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
              ),
              const SizedBox(height: 20),

              // 4. Action CTA Button (Emerald Green Duolingo Style Button)
              GameButton(
                text: '⭐ GOT IT! TRY NEXT ⭐',
                backgroundColor: GameColors.freshGreen,
                shadowColor: GameColors.freshGreenDark,
                textColor: Colors.white,
                onPressed: onContinue,
                height: 52,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
