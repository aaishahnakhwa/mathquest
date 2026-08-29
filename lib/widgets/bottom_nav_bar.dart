import 'package:flutter/material.dart';
import '../theme/colors.dart';

class BottomGameNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomGameNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      {'emoji': '🏠', 'label': 'HOME'},
      {'emoji': '🗺️', 'label': 'MAP'},
      {'emoji': '🎁', 'label': 'REWARDS'},
      {'emoji': '🏆', 'label': 'BADGES'},
      {'emoji': '👤', 'label': 'SHOP'},
    ];

    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: GameColors.surfaceWarm,
        border: const Border(
          top: BorderSide(color: GameColors.cardBorder, width: 2),
        ),
        boxShadow: [
          BoxShadow(
            color: GameColors.navyText.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final isSelected = currentIndex == index;
          final item = items[index];

          return GestureDetector(
            onTap: () => onTap(index),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: isSelected
                  ? BoxDecoration(
                      color: GameColors.turquoise.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: GameColors.turquoise.withOpacity(0.4),
                          width: 1.5),
                    )
                  : null,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedScale(
                    scale: isSelected ? 1.2 : 1.0,
                    duration: const Duration(milliseconds: 150),
                    child: Text(
                      item['emoji'] as String,
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item['label'] as String,
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 11,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected
                          ? GameColors.skyBlueDark
                          : GameColors.navyTextMuted,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
