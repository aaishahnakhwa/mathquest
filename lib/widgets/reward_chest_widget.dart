import 'package:flutter/material.dart';
import '../theme/colors.dart';

class RewardChestWidget extends StatefulWidget {
  final VoidCallback? onOpen;
  final bool isOpen;

  const RewardChestWidget({
    super.key,
    this.onOpen,
    this.isOpen = false,
  });

  @override
  State<RewardChestWidget> createState() => _RewardChestWidgetState();
}

class _RewardChestWidgetState extends State<RewardChestWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: 0.0, end: -12.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onOpen,
      child: AnimatedBuilder(
        animation: _bounceAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, widget.isOpen ? 0 : _bounceAnimation.value),
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: GameColors.sunnyYellow.withOpacity(0.2),
                border: Border.all(color: GameColors.sunnyYellow, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: GameColors.sunnyYellow.withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  widget.isOpen ? '🎁' : '🧰',
                  style: const TextStyle(fontSize: 70),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
