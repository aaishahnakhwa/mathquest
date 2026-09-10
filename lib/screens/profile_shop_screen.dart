import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/game_provider.dart';
import '../services/audio_service.dart';
import '../models/shop_model.dart';
import '../theme/colors.dart';
import '../widgets/avatar_widget.dart';
import '../widgets/game_button.dart';

class ProfileAndShopScreen extends StatefulWidget {
  const ProfileAndShopScreen({super.key});

  @override
  State<ProfileAndShopScreen> createState() => _ProfileAndShopScreenState();
}

class _ProfileAndShopScreenState extends State<ProfileAndShopScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            // Top Tab Bar (PROFILE / SHOP)
            Container(
              color: GameColors.surfaceWarm,
              child: TabBar(
                controller: _tabController,
                indicatorColor: GameColors.turquoise,
                indicatorWeight: 3,
                labelColor: GameColors.skyBlueDark,
                unselectedLabelColor: GameColors.navyTextMuted,
                labelStyle: const TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
                tabs: const [
                  Tab(text: '👤 HERO PROFILE'),
                  Tab(text: '🛒 GAME SHOP'),
                ],
              ),
            ),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildProfileTab(context, provider),
                  _buildShopTab(context, provider),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfileTab(BuildContext context, GameProvider provider) {
    final player = provider.player;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Hero Studio Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: GameColors.skyGradient,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: GameColors.skyBlueDark.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                AvatarWidget(
                  avatarId: player.avatarId,
                  equippedHatId: player.equippedHatId,
                  equippedOutfitId: player.equippedOutfitId,
                  size: 90,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      player.name,
                      style: const TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.edit_rounded,
                        color: Colors.white70,
                        size: 20,
                      ),
                      onPressed: () => _showEditNameDialog(context, provider),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: GameColors.sunnyYellow,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    'Level ${player.level} Math Hero',
                    style: const TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: GameColors.navyText,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Player Statistics Grid
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'HERO STATS',
              style: TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: GameColors.navyText,
              ),
            ),
          ),
          const SizedBox(height: 12),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _buildStatCard(
                '🔥 Streak',
                '${player.streakDays} Days',
                GameColors.streakOrange,
              ),
              _buildStatCard(
                '⭐ Total Stars',
                '${player.totalStars}',
                GameColors.coinGold,
              ),
              _buildStatCard(
                '🎯 Accuracy',
                '${player.accuracyPercentage.toStringAsFixed(0)}%',
                GameColors.freshGreen,
              ),
              _buildStatCard(
                '🧠 Solved',
                '${player.questionsSolved} Qs',
                GameColors.xpBlue,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // SOFT PIANO MUSIC SETTINGS
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '🎵 SOFT PIANO MUSIC',
              style: TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: GameColors.navyText,
              ),
            ),
          ),
          const SizedBox(height: 12),

          Consumer<AudioService>(
            builder: (context, audioService, child) {
              return Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: GameColors.skyBlueDark.withValues(alpha: 0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: GameColors.skyBlueDark.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Background Music Master Switch
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: GameColors.skyBlue.withValues(
                                  alpha: 0.15,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.music_note_rounded,
                                color: GameColors.skyBlueDark,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Soft Piano Melody',
                                  style: TextStyle(
                                    fontFamily: 'Fredoka',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: GameColors.navyText,
                                  ),
                                ),
                                Text(
                                  'Calm background music',
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 12,
                                    color: GameColors.navyTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Switch(
                          value: audioService.isMusicEnabled,
                          activeThumbColor: GameColors.skyBlueDark,
                          activeTrackColor: GameColors.skyBlue.withValues(
                            alpha: 0.3,
                          ),
                          onChanged: (val) => audioService.toggleMusic(),
                        ),
                      ],
                    ),

                    const Divider(height: 24),

                    // Volume Slider (Always accessible)
                    Row(
                      children: [
                        Icon(
                          audioService.isMusicEnabled
                              ? Icons.volume_up_rounded
                              : Icons.volume_off_rounded,
                          size: 20,
                          color: audioService.isMusicEnabled
                              ? GameColors.skyBlueDark
                              : Colors.grey,
                        ),
                        Expanded(
                          child: SliderTheme(
                            data: SliderThemeData(
                              activeTrackColor: GameColors.skyBlueDark,
                              inactiveTrackColor: GameColors.skyBlue.withValues(
                                alpha: 0.2,
                              ),
                              thumbColor: GameColors.skyBlueDark,
                              overlayColor: GameColors.skyBlue.withValues(
                                alpha: 0.15,
                              ),
                            ),
                            child: Slider(
                              value: audioService.musicVolume,
                              min: 0.0,
                              max: 1.0,
                              onChanged: (val) =>
                                  audioService.setMusicVolume(val),
                            ),
                          ),
                        ),
                        Text(
                          '${(audioService.musicVolume * 100).toInt()}%',
                          style: TextStyle(
                            fontFamily: 'Fredoka',
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: audioService.isMusicEnabled
                                ? GameColors.skyBlueDark
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // 2. GAMEPLAY PREFERENCES
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '🎮 GAMEPLAY PREFERENCES',
              style: TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: GameColors.navyText,
              ),
            ),
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: GameColors.turquoise.withValues(alpha: 0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: GameColors.turquoise.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Haptics Toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Text('📳', style: TextStyle(fontSize: 22)),
                        SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Haptic Vibration',
                              style: TextStyle(
                                fontFamily: 'Fredoka',
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: GameColors.navyText,
                              ),
                            ),
                            Text(
                              'Tactile touch feedback on tap',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 12,
                                color: GameColors.navyTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Switch(
                      value: player.isHapticsEnabled,
                      activeThumbColor: GameColors.turquoise,
                      onChanged: (val) => provider.toggleHaptics(),
                    ),
                  ],
                ),

                const Divider(height: 20),

                // Auto Show Explanations Toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Text('💡', style: TextStyle(fontSize: 22)),
                        SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Auto Explanations',
                              style: TextStyle(
                                fontFamily: 'Fredoka',
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: GameColors.navyText,
                              ),
                            ),
                            Text(
                              'Show solution guide on mistakes',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 12,
                                color: GameColors.navyTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Switch(
                      value: player.autoShowExplanations,
                      activeThumbColor: GameColors.turquoise,
                      onChanged: (val) => provider.toggleAutoShowExplanations(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 3. DATA & DANGER ZONE
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '⚙️ DATA & MANAGEMENT',
              style: TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: GameColors.navyText,
              ),
            ),
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.red.shade200, width: 2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reset Progress',
                      style: TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    Text(
                      'Clear stats & restart adventure',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12,
                        color: GameColors.navyTextSecondary,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () => _showResetConfirmDialog(context, provider),
                  child: const Text(
                    'RESET',
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  void _showEditNameDialog(BuildContext context, GameProvider provider) {
    final controller = TextEditingController(text: provider.player.name);
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            '✏️ Change Hero Name',
            style: TextStyle(fontFamily: 'Fredoka', color: GameColors.navyText),
          ),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Enter new hero name...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: GameColors.skyBlue,
              ),
              onPressed: () {
                provider.updatePlayerName(controller.text);
                Navigator.pop(ctx);
              },
              child: const Text('SAVE', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showResetConfirmDialog(BuildContext context, GameProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            '⚠️ Reset All Progress?',
            style: TextStyle(fontFamily: 'Fredoka', color: Colors.red),
          ),
          content: const Text(
            'Are you sure you want to reset all stars, coins, level unlocks, and progress? This cannot be undone.',
            style: TextStyle(fontFamily: 'Nunito'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                provider.resetGameProgress();
                Navigator.pop(ctx);
              },
              child: const Text(
                'YES, RESET',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.06), blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: GameColors.navyText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShopTab(BuildContext context, GameProvider provider) {
    final shopItems = provider.shopItems;

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: shopItems.length,
      separatorBuilder: (context, index) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final item = shopItems[index];
        final isUnlocked =
            provider.player.inventoryItemIds.contains(item.id) ||
            item.isUnlocked;
        final isEquipped =
            (item.id == provider.player.equippedHatId ||
            item.id == provider.player.equippedOutfitId ||
            item.id == provider.player.equippedAccessoryId);

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isEquipped ? GameColors.turquoise : GameColors.cardBorder,
              width: isEquipped ? 2.5 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: GameColors.navyText.withValues(alpha: 0.06),
                blurRadius: 6,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: GameColors.skyBlueLight,
                ),
                child: Center(
                  child: Text(
                    item.iconEmoji,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: GameColors.navyText,
                      ),
                    ),
                    Text(
                      item.description,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12,
                        color: GameColors.navyTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              if (isEquipped)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: GameColors.turquoise.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'EQUIPPED',
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: GameColors.turquoise,
                    ),
                  ),
                )
              else if (isUnlocked)
                GameButton(
                  text: 'EQUIP',
                  backgroundColor: GameColors.skyBlue,
                  shadowColor: GameColors.skyBlueDark,
                  textColor: Colors.white,
                  height: 38,
                  fontSize: 12,
                  onPressed: () => provider.equipShopItem(item),
                )
              else
                GameButton(
                  text:
                      '${item.currency == CurrencyType.coins ? '💰' : '💎'} ${item.price}',
                  backgroundColor: GameColors.sunnyYellow,
                  shadowColor: GameColors.yellowDark,
                  textColor: GameColors.navyText,
                  height: 38,
                  fontSize: 12,
                  onPressed: () => provider.purchaseShopItem(item),
                ),
            ],
          ),
        );
      },
    );
  }
}
