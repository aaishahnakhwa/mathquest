import 'package:flutter/material.dart';

import '../theme/colors.dart';

class MathGuideWidget extends StatelessWidget {
  final String text;
  final String title;

  const MathGuideWidget({
    super.key,
    required this.text,
    this.title = 'PROFESSOR OWL',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: GameColors.surfaceWarm,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: GameColors.skyBlue, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: GameColors.navyText.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: GameColors.skyBlueLight,
              shape: BoxShape.circle,
              border: Border.all(color: GameColors.skyBlue, width: 2),
            ),
            child: const Text('🦉', style: TextStyle(fontSize: 32)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: GameColors.skyBlueDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  text,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: GameColors.navyText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
