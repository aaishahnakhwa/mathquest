import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/game_provider.dart';
import '../widgets/game_hud_bar.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/cheat_code_access_button.dart';
import 'home_screen.dart';
import 'adventure_map_screen.dart';
import 'rewards_screen.dart';
import 'achievements_screen.dart';
import 'profile_shop_screen.dart';

class MainShellScreen extends StatelessWidget {
  const MainShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final screens = const [
          HomeScreen(),
          AdventureMapScreen(),
          RewardsScreen(),
          AchievementsScreen(),
          ProfileAndShopScreen(),
        ];

        return Scaffold(
          appBar: const GameHudBar(),
          body: Stack(
            children: [
              IndexedStack(index: provider.currentTab, children: screens),
              const Positioned(
                right: 12,
                bottom: 12,
                child: CheatCodeAccessButton(),
              ),
            ],
          ),
          bottomNavigationBar: BottomGameNavBar(
            currentIndex: provider.currentTab,
            onTap: (index) => provider.setCurrentTab(index),
          ),
        );
      },
    );
  }
}
