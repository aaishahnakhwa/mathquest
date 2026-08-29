import 'package:flutter/material.dart';
import '../theme/colors.dart';

class AvatarWidget extends StatelessWidget {
  final String avatarId;
  final String equippedHatId;
  final String equippedOutfitId;
  final double size;
  final bool showBorder;

  const AvatarWidget({
    super.key,
    required this.avatarId,
    this.equippedHatId = 'hat_wizard_starter',
    this.equippedOutfitId = 'outfit_explorer',
    this.size = 50,
    this.showBorder = true,
  });

  String _getHatEmoji() {
    if (avatarId == 'hero_wizard') {
      return '';
    }
    switch (equippedHatId) {
      case 'hat_crown_gold':
        return '👑';
      case 'hat_viking_helm':
        return '🪖';
      default:
        return '';
    }
  }

  String _getAvatarFace() {
    switch (avatarId) {
      case 'hero_girl':
        return '👧';
      case 'hero_boy':
        return '👦';
      case 'hero_wizard':
      default:
        return '🧙‍♂️';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isWizard = avatarId == 'hero_wizard';
    final hatEmoji = _getHatEmoji();

    if (isWizard) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: GameColors.navyText.withValues(alpha: 0.15),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipOval(
          child: Image.asset(
            'assets/images/wizard_avatar.png',
            width: size,
            height: size,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: GameColors.skyGradient,
        border: showBorder
            ? Border.all(color: GameColors.sunnyYellow, width: size * 0.06)
            : null,
        boxShadow: [
          BoxShadow(
            color: GameColors.navyText.withValues(alpha: 0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: Text(
                _getAvatarFace(),
                style: TextStyle(fontSize: size * 0.55),
              ),
            ),
            if (hatEmoji.isNotEmpty)
              Positioned(
                top: -size * 0.05,
                right: size * 0.05,
                child: Text(
                  hatEmoji,
                  style: TextStyle(fontSize: size * 0.35),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
