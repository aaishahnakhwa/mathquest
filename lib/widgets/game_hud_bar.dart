import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../theme/colors.dart';
import 'avatar_widget.dart';
import 'music_toggle_button.dart';

class GameHudBar extends StatelessWidget implements PreferredSizeWidget {
  const GameHudBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, provider, child) {
        final player = provider.player;

        return Container(
          decoration: BoxDecoration(
            color: GameColors.surfaceWarm,
            boxShadow: [
              BoxShadow(
                color: GameColors.navyText.withValues(alpha: 0.08),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
            border: const Border(
              bottom: BorderSide(color: GameColors.cardBorder, width: 2),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: 56,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    // Avatar & Hero Level Compact Badge Row
                    GestureDetector(
                      onTap: () => provider.setCurrentTab(4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AvatarWidget(
                            avatarId: player.avatarId,
                            equippedHatId: player.equippedHatId,
                            equippedOutfitId: player.equippedOutfitId,
                            size: 32,
                          ),
                          const SizedBox(width: 4),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 55),
                            child: Text(
                              player.name,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Fredoka',
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: GameColors.navyText,
                              ),
                            ),
                          ),
                          const SizedBox(width: 3),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: GameColors.skyBlue,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Lv.${player.level}',
                              style: const TextStyle(
                                fontFamily: 'Fredoka',
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),

                    // XP Progress Bar
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'XP',
                                style: TextStyle(
                                  fontFamily: 'Fredoka',
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: GameColors.xpBlue,
                                ),
                              ),
                              Text(
                                '${player.currentXp}/${player.xpForNextLevel}',
                                style: const TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: GameColors.navyTextSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Stack(
                              children: [
                                Container(
                                  height: 6,
                                  color: Colors.grey.shade300,
                                ),
                                FractionallySizedBox(
                                  widthFactor: player.xpProgressRatio,
                                  child: Container(
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          GameColors.skyBlue,
                                          GameColors.turquoise
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),

                    // Currency Pills (Coins, Gems)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildCurrencyPill(
                          emoji: '💰',
                          value: '${player.coins}',
                          bgColor: GameColors.sunnyYellow.withValues(alpha: 0.2),
                          textColor: GameColors.yellowDark,
                        ),
                        const SizedBox(width: 2),
                        _buildCurrencyPill(
                          emoji: '💎',
                          value: '${player.gems}',
                          bgColor: GameColors.gemPurple.withValues(alpha: 0.15),
                          textColor: GameColors.gemPurple,
                        ),
                      ],
                    ),
                    const SizedBox(width: 4),

                    // Glossy Theme-Matched Soft Piano Music Button
                    const MusicToggleButton(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCurrencyPill({
    String? emoji,
    Widget? customIcon,
    required String value,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: textColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (customIcon != null)
            customIcon
          else if (emoji != null)
            Text(emoji, style: const TextStyle(fontSize: 10)),
          const SizedBox(width: 2),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
