import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
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
                  color: GameColors.skyBlueDark.withOpacity(0.3),
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
                Text(
                  player.name,
                  style: const TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
              _buildStatCard('🔥 Streak', '${player.streakDays} Days',
                  GameColors.streakOrange),
              _buildStatCard('⭐ Total Stars', '${player.totalStars}',
                  GameColors.coinGold),
              _buildStatCard('🎯 Accuracy',
                  '${player.accuracyPercentage.toStringAsFixed(0)}%', GameColors.freshGreen),
              _buildStatCard('🧠 Solved', '${player.questionsSolved} Qs',
                  GameColors.xpBlue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.06),
            blurRadius: 6,
          ),
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
        final isUnlocked = provider.player.inventoryItemIds.contains(item.id) ||
            item.isUnlocked;
        final isEquipped = (item.id == provider.player.equippedHatId ||
            item.id == provider.player.equippedOutfitId ||
            item.id == provider.player.equippedAccessoryId);

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isEquipped
                  ? GameColors.turquoise
                  : GameColors.cardBorder,
              width: isEquipped ? 2.5 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: GameColors.navyText.withOpacity(0.06),
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
                  child: Text(item.iconEmoji,
                      style: const TextStyle(fontSize: 28)),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: GameColors.turquoise.withOpacity(0.2),
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
