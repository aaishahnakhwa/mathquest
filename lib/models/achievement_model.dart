class AchievementModel {
  final String id;
  final String title;
  final String description;
  final String iconEmoji;
  final double requiredProgress;
  final double currentProgress;
  final int rewardCoins;
  final int rewardGems;
  final bool isClaimed;

  const AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.iconEmoji,
    required this.requiredProgress,
    this.currentProgress = 0,
    this.rewardCoins = 50,
    this.rewardGems = 2,
    this.isClaimed = false,
  });

  bool get isCompleted => currentProgress >= requiredProgress;

  AchievementModel copyWith({
    double? currentProgress,
    bool? isClaimed,
  }) {
    return AchievementModel(
      id: id,
      title: title,
      description: description,
      iconEmoji: iconEmoji,
      requiredProgress: requiredProgress,
      currentProgress: currentProgress ?? this.currentProgress,
      rewardCoins: rewardCoins,
      rewardGems: rewardGems,
      isClaimed: isClaimed ?? this.isClaimed,
    );
  }
}
