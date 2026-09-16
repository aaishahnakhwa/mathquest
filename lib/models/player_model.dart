import 'dart:convert';

class PlayerModel {
  final String id;
  final String name;
  final String avatarId;
  final int level;
  final int currentXp;
  final int totalXp;
  final int coins;
  final int gems;
  final int streakDays;
  final String lastPlayDate;
  final String equippedHatId;
  final Set<String> completedLevelIds;
  final Set<String> unlockedWorldIds;
  final Map<String, int> levelStars;
  final List<String> inventoryItemIds;
  final int woodLogs;
  final Map<String, int> buildingStages;
  final int questionsSolved;
  final int correctAnswers;
  final bool isHapticsEnabled;
  final bool autoShowExplanations;
  final bool onboardingCompleted;
  final String lastDailyRewardAt;
  final String lastDailyChestAt;
  final Set<String> claimedAchievementIds;
  final Set<String> perfectLevelIds;
  final int lifetimeCoinsEarned;

  const PlayerModel({
    this.id = 'player_1',
    this.name = 'Math Explorer',
    this.avatarId = 'owl_guide',
    this.level = 1,
    this.currentXp = 0,
    this.totalXp = 0,
    this.coins = 100,
    this.gems = 5, // 5 Starter Gems as requested!
    this.woodLogs = 5, // 5 Starter Wood Logs!
    this.buildingStages = const {},
    this.streakDays = 0,
    this.lastPlayDate = '',
    this.equippedHatId = 'hat_wizard_starter',
    this.completedLevelIds = const {},
    this.unlockedWorldIds = const {'world_1'},
    this.levelStars = const {},
    this.inventoryItemIds = const ['hat_wizard_starter'],
    this.questionsSolved = 0,
    this.correctAnswers = 0,
    this.isHapticsEnabled = true,
    this.autoShowExplanations = true,
    this.onboardingCompleted = false,
    this.lastDailyRewardAt = '',
    this.lastDailyChestAt = '',
    this.claimedAchievementIds = const {},
    this.perfectLevelIds = const {},
    this.lifetimeCoinsEarned = 100,
  });

  int get xpForNextLevel => level * 100;
  double get xpProgressRatio => (currentXp / xpForNextLevel).clamp(0.0, 1.0);
  int get totalStars => levelStars.values.fold(0, (sum, stars) => sum + stars);

  String get currentWorldId => unlockedWorldIds.contains('world_3')
      ? 'world_3'
      : unlockedWorldIds.contains('world_2')
      ? 'world_2'
      : 'world_1';

  double get accuracyPercentage => questionsSolved == 0
      ? 100.0
      : ((correctAnswers / questionsSolved) * 100).clamp(0.0, 100.0);

  PlayerModel copyWith({
    String? id,
    String? name,
    String? avatarId,
    int? level,
    int? currentXp,
    int? totalXp,
    int? coins,
    int? gems,
    int? woodLogs,
    Map<String, int>? buildingStages,
    int? streakDays,
    String? lastPlayDate,
    String? equippedHatId,
    Set<String>? completedLevelIds,
    Set<String>? unlockedWorldIds,
    Map<String, int>? levelStars,
    List<String>? inventoryItemIds,
    int? questionsSolved,
    int? correctAnswers,
    bool? isHapticsEnabled,
    bool? autoShowExplanations,
    bool? onboardingCompleted,
    String? lastDailyRewardAt,
    String? lastDailyChestAt,
    Set<String>? claimedAchievementIds,
    Set<String>? perfectLevelIds,
    int? lifetimeCoinsEarned,
  }) {
    return PlayerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarId: avatarId ?? this.avatarId,
      level: level ?? this.level,
      currentXp: currentXp ?? this.currentXp,
      totalXp: totalXp ?? this.totalXp,
      coins: coins ?? this.coins,
      gems: gems ?? this.gems,
      woodLogs: woodLogs ?? this.woodLogs,
      buildingStages: buildingStages ?? this.buildingStages,
      streakDays: streakDays ?? this.streakDays,
      lastPlayDate: lastPlayDate ?? this.lastPlayDate,
      equippedHatId: equippedHatId ?? this.equippedHatId,
      completedLevelIds: completedLevelIds ?? this.completedLevelIds,
      unlockedWorldIds: unlockedWorldIds ?? this.unlockedWorldIds,
      levelStars: levelStars ?? this.levelStars,
      inventoryItemIds: inventoryItemIds ?? this.inventoryItemIds,
      questionsSolved: questionsSolved ?? this.questionsSolved,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      isHapticsEnabled: isHapticsEnabled ?? this.isHapticsEnabled,
      autoShowExplanations: autoShowExplanations ?? this.autoShowExplanations,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      lastDailyRewardAt: lastDailyRewardAt ?? this.lastDailyRewardAt,
      lastDailyChestAt: lastDailyChestAt ?? this.lastDailyChestAt,
      claimedAchievementIds:
          claimedAchievementIds ?? this.claimedAchievementIds,
      perfectLevelIds: perfectLevelIds ?? this.perfectLevelIds,
      lifetimeCoinsEarned: lifetimeCoinsEarned ?? this.lifetimeCoinsEarned,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'avatarId': avatarId,
      'level': level,
      'currentXp': currentXp,
      'totalXp': totalXp,
      'coins': coins,
      'gems': gems,
      'woodLogs': woodLogs,
      'buildingStages': buildingStages,
      'streakDays': streakDays,
      'lastPlayDate': lastPlayDate,
      'equippedHatId': equippedHatId,
      'completedLevelIds': completedLevelIds.toList(),
      'unlockedWorldIds': unlockedWorldIds.toList(),
      'levelStars': levelStars,
      'inventoryItemIds': inventoryItemIds,
      'questionsSolved': questionsSolved,
      'correctAnswers': correctAnswers,
      'isHapticsEnabled': isHapticsEnabled,
      'autoShowExplanations': autoShowExplanations,
      'onboardingCompleted': onboardingCompleted,
      'lastDailyRewardAt': lastDailyRewardAt,
      'lastDailyChestAt': lastDailyChestAt,
      'claimedAchievementIds': claimedAchievementIds.toList(),
      'perfectLevelIds': perfectLevelIds.toList(),
      'lifetimeCoinsEarned': lifetimeCoinsEarned,
    };
  }

  factory PlayerModel.fromMap(Map<String, dynamic> map) {
    return PlayerModel(
      id: map['id'] ?? 'player_1',
      name: map['name'] ?? 'Math Explorer',
      avatarId: map['avatarId'] == 'hero_boy'
          ? 'hero_wizard'
          : map['avatarId'] ?? 'owl_guide',
      level: map['level'] ?? 1,
      currentXp: map['currentXp'] ?? 0,
      totalXp: map['totalXp'] ?? 0,
      coins: map['coins'] ?? 100,
      gems: map['gems'] ?? 5,
      woodLogs: map['woodLogs'] ?? 5,
      buildingStages: Map<String, int>.from(map['buildingStages'] ?? {}),
      streakDays: map['streakDays'] ?? 0,
      lastPlayDate: map['lastPlayDate'] ?? '',
      equippedHatId: map['equippedHatId'] ?? 'hat_wizard_starter',
      completedLevelIds: Set<String>.from(map['completedLevelIds'] ?? []),
      unlockedWorldIds: Set<String>.from(
        map['unlockedWorldIds'] ?? ['world_1'],
      ),
      levelStars: Map<String, int>.from(map['levelStars'] ?? {}),
      inventoryItemIds: List<String>.from(
        map['inventoryItemIds'] ?? ['hat_wizard_starter'],
      ),
      questionsSolved: map['questionsSolved'] ?? 0,
      correctAnswers: map['correctAnswers'] ?? 0,
      isHapticsEnabled: map['isHapticsEnabled'] ?? true,
      autoShowExplanations: map['autoShowExplanations'] ?? true,
      onboardingCompleted:
          map['onboardingCompleted'] ??
          ((map['questionsSolved'] ?? 0) > 0 ||
              Map<String, dynamic>.from(map['levelStars'] ?? {}).isNotEmpty),
      lastDailyRewardAt: map['lastDailyRewardAt'] ?? '',
      lastDailyChestAt: map['lastDailyChestAt'] ?? '',
      claimedAchievementIds: Set<String>.from(
        map['claimedAchievementIds'] ?? const [],
      ),
      perfectLevelIds: Set<String>.from(
        map['perfectLevelIds'] ??
            Map<String, int>.from(map['levelStars'] ?? const {}).entries
                .where((entry) => entry.value == 3)
                .map((entry) => entry.key),
      ),
      lifetimeCoinsEarned: map['lifetimeCoinsEarned'] ?? map['coins'] ?? 100,
    );
  }

  String serialize() => jsonEncode(toMap());

  factory PlayerModel.deserialize(String jsonStr) =>
      PlayerModel.fromMap(jsonDecode(jsonStr));
}
