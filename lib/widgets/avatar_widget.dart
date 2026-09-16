import 'package:flutter/material.dart';

import '../theme/colors.dart';

class AvatarWidget extends StatelessWidget {
  static const maleWizardId = 'hero_wizard';
  static const femaleWizardId = 'hero_girl';
  static const wizardAvatarAsset = 'assets/images/wizard_avatar.png';
  static const femaleWizardAvatarAsset =
      'assets/images/female_wizard_avatar.png';
  static const wizardCharacterAsset = 'assets/images/wizard_character.png';
  static const femaleWizardCharacterAsset = 'assets/images/female_wizard.png';

  static bool isFemaleWizard(String avatarId) => avatarId == femaleWizardId;

  static String? mapCharacterAssetFor(String avatarId) {
    return switch (avatarId) {
      maleWizardId => wizardCharacterAsset,
      femaleWizardId => femaleWizardCharacterAsset,
      _ => null,
    };
  }

  final String avatarId;
  final String equippedHatId;
  final double size;
  final bool showBorder;

  const AvatarWidget({
    super.key,
    required this.avatarId,
    this.equippedHatId = 'hat_wizard_starter',
    this.size = 50,
    this.showBorder = true,
  });

  String _getHatEmoji() {
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
      case femaleWizardId:
        return '👧';
      case maleWizardId:
      default:
        return '🧙‍♂️';
    }
  }

  String? _getIllustratedAvatarAsset() {
    return switch (avatarId) {
      maleWizardId => wizardAvatarAsset,
      femaleWizardId => femaleWizardAvatarAsset,
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final illustratedAvatarAsset = _getIllustratedAvatarAsset();
    final hatEmoji = _getHatEmoji();

    if (illustratedAvatarAsset != null) {
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
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                illustratedAvatarAsset,
                width: size,
                height: size,
                fit: BoxFit.cover,
              ),
              if (hatEmoji.isNotEmpty)
                Positioned(
                  top: size * 0.01,
                  right: size * 0.08,
                  child: Text(
                    hatEmoji,
                    style: TextStyle(fontSize: size * 0.34),
                  ),
                ),
            ],
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
                child: Text(hatEmoji, style: TextStyle(fontSize: size * 0.35)),
              ),
          ],
        ),
      ),
    );
  }
}
