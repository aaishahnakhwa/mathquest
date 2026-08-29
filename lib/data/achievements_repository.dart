import '../models/achievement_model.dart';

class AchievementsRepository {
  static List<AchievementModel> getDefaultAchievements() {
    return const [
      AchievementModel(
        id: 'ach_first_quest',
        title: 'First Quest',
        description: 'Complete your very first level on the map.',
        iconEmoji: '🚩',
        requiredProgress: 1,
        rewardCoins: 50,
        rewardGems: 3,
      ),
      AchievementModel(
        id: 'ach_math_wizard',
        title: 'Math Wizard',
        description: 'Collect 15 golden stars across all worlds.',
        iconEmoji: '⭐',
        requiredProgress: 15,
        rewardCoins: 150,
        rewardGems: 5,
      ),
      AchievementModel(
        id: 'ach_streak_master',
        title: 'Streak Master',
        description: 'Maintain a 7-day daily quest streak.',
        iconEmoji: '🔥',
        requiredProgress: 7,
        rewardCoins: 200,
        rewardGems: 10,
      ),
      AchievementModel(
        id: 'ach_no_mistakes',
        title: 'No Mistakes',
        description: 'Complete a level with 100% accuracy.',
        iconEmoji: '🧠',
        requiredProgress: 1,
        rewardCoins: 100,
        rewardGems: 4,
      ),
      AchievementModel(
        id: 'ach_world_explorer',
        title: 'World Explorer',
        description: 'Unlock World 2 (Fraction Forest).',
        iconEmoji: '🌳',
        requiredProgress: 1,
        rewardCoins: 250,
        rewardGems: 8,
      ),
      AchievementModel(
        id: 'ach_fraction_hero',
        title: 'Fraction Hero',
        description: 'Solve 10 fraction questions correctly.',
        iconEmoji: '🍰',
        requiredProgress: 10,
        rewardCoins: 120,
        rewardGems: 5,
      ),
      AchievementModel(
        id: 'ach_coin_collector',
        title: 'Treasure Hunter',
        description: 'Accumulate 500 gold coins.',
        iconEmoji: '💰',
        requiredProgress: 500,
        rewardCoins: 100,
        rewardGems: 5,
      ),
    ];
  }
}
