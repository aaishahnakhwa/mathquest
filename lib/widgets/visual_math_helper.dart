import 'package:flutter/material.dart';
import '../theme/colors.dart';

class VisualMathHelper extends StatelessWidget {
  final String questionText;
  final String topic;

  const VisualMathHelper({
    super.key,
    required this.questionText,
    required this.topic,
  });

  @override
  Widget build(BuildContext context) {
    final numbers = RegExp(r'\d+').allMatches(questionText).map((m) => int.parse(m.group(0)!)).toList();

    if (numbers.length >= 2 && (topic.contains('Addition') || topic.contains('Subtraction') || questionText.contains('+') || questionText.contains('-'))) {
      final num1 = numbers[0];
      final num2 = numbers[1];
      final isAddition = questionText.contains('+') || topic.contains('Addition');

      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFCBD5E1), width: 2),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFF94A3B8),
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            children: [
              // Glossy Background Gradient
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white,
                        Color(0xFFF8FAFC),
                        Color(0xFFF1F5F9),
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
                height: 18,
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
              // Helper Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.bar_chart_rounded, size: 14, color: GameColors.navyTextMuted),
                        const SizedBox(width: 4),
                        const Text(
                          'VISUAL BLOCK HELPER:',
                          style: TextStyle(
                            fontFamily: 'Fredoka',
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: GameColors.navyTextMuted,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // 1st Number 3D Glossy Block Group (Blue)
                        _build3DBlockGroup(
                          count: num1,
                          fillColor: const Color(0xFF2563EB),
                          topColor: const Color(0xFF93C5FD),
                          bottomColor: const Color(0xFF1D4ED8),
                          textColor: const Color(0xFF1D4ED8),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14.0),
                          child: Text(
                            isAddition ? '+' : '-',
                            style: const TextStyle(
                              fontFamily: 'Fredoka',
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: GameColors.navyText,
                            ),
                          ),
                        ),
                        // 2nd Number 3D Glossy Block Group (Green)
                        _build3DBlockGroup(
                          count: num2,
                          fillColor: const Color(0xFF16A34A),
                          topColor: const Color(0xFF86EFAC),
                          bottomColor: const Color(0xFF15803D),
                          textColor: const Color(0xFF15803D),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _build3DBlockGroup({
    required int count,
    required Color fillColor,
    required Color topColor,
    required Color bottomColor,
    required Color textColor,
  }) {
    final displayCount = count.clamp(1, 10);

    return Column(
      children: [
        Wrap(
          spacing: 3.5,
          runSpacing: 3.5,
          alignment: WrapAlignment.center,
          children: List.generate(
            displayCount,
            (index) => Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: fillColor,
                borderRadius: BorderRadius.circular(4),
                border: Border(
                  top: BorderSide(color: topColor, width: 2.5),
                  left: BorderSide(color: topColor, width: 2),
                  right: BorderSide(color: bottomColor, width: 2),
                  bottom: BorderSide(color: bottomColor, width: 3),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 3,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$count',
          style: TextStyle(
            fontFamily: 'Fredoka',
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    );
  }
}
