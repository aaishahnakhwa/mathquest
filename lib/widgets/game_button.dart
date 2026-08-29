import 'package:flutter/material.dart';
import '../theme/colors.dart';

class GameButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color shadowColor;
  final Color textColor;
  final Widget? icon;
  final double height;
  final double? width;
  final double fontSize;
  final bool isLoading;

  const GameButton({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor = GameColors.sunnyYellow,
    this.shadowColor = GameColors.yellowDark,
    this.textColor = GameColors.navyText,
    this.icon,
    this.height = 54,
    this.width,
    this.fontSize = 18,
    this.isLoading = false,
  });

  @override
  State<GameButton> createState() => _GameButtonState();
}

class _GameButtonState extends State<GameButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null && !widget.isLoading;
    final topPadding = _isPressed ? 6.0 : 0.0;
    final bottomPadding = _isPressed ? 0.0 : 6.0;

    return GestureDetector(
      onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: isEnabled ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: isEnabled ? () => setState(() => _isPressed = false) : null,
      onTap: isEnabled ? widget.onPressed : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        width: widget.width,
        height: widget.height,
        margin: EdgeInsets.only(top: topPadding, bottom: bottomPadding),
        decoration: BoxDecoration(
          color: isEnabled
              ? widget.backgroundColor
              : GameColors.nodeLocked.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: isEnabled ? widget.shadowColor : Colors.grey.shade400,
            width: 2.5,
          ),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: widget.shadowColor,
                    offset: const Offset(0, 5),
                    blurRadius: 0,
                  ),
                  BoxShadow(
                    color: GameColors.navyText.withValues(alpha: 0.18),
                    offset: const Offset(0, 9),
                    blurRadius: 8,
                  ),
                ]
              : [],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Top Glassy Highlight Strip (Candy Specular Reflection)
              if (isEnabled)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: widget.height * 0.45,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(alpha: 0.5),
                          Colors.white.withValues(alpha: 0.05),
                        ],
                      ),
                    ),
                  ),
                ),

              // Button Content Text & Icon
              Center(
                child: widget.isLoading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(widget.textColor),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.icon != null) ...[
                            widget.icon!,
                            const SizedBox(width: 8),
                          ],
                          Text(
                            widget.text,
                            style: TextStyle(
                              fontFamily: 'Fredoka',
                              fontSize: widget.fontSize,
                              fontWeight: FontWeight.bold,
                              color: isEnabled ? widget.textColor : Colors.grey.shade600,
                              letterSpacing: 0.6,
                              shadows: isEnabled
                                  ? const [
                                      Shadow(
                                        color: Colors.black12,
                                        offset: Offset(1, 1.5),
                                        blurRadius: 2,
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
