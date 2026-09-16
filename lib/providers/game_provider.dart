import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/player_model.dart';
import '../models/world_model.dart';
import '../models/level_model.dart';
import '../models/question_model.dart';
import '../models/achievement_model.dart';
import '../models/shop_model.dart';
import '../data/world_repository.dart';
import '../data/achievements_repository.dart';
import '../data/shop_repository.dart';

class GameProvider extends ChangeNotifier {
  static const int levelHouseFinalStage = 4;

  PlayerModel _player = const PlayerModel();
  List<WorldModel> _worlds = [];
  List<AchievementModel> _achievements = [];
  List<ShopItemModel> _shopItems = [];

  bool _isLoading = true;
  int _currentTab = 1; // Default tab: Map
  bool _isTestMode = false;

  // Active Gameplay Session State
  LevelModel? _activeLevel;
  int _currentQuestionIndex = 0;
  int? _selectedAnswerIndex;
  bool _isAnswerSubmitted = false;
  bool _isCorrectAnswer = false;
  int _levelCorrectCount = 0;
  int _levelHeartsLeft = 3;
  int _hintsUsedInLevel = 0;
  bool _showExplanation = false;

  // Level Complete Dialog/Screen State
  bool _isLevelCompleted = false;
  bool _didPassLevel = false;
  int _earnedStars = 0;
  int _earnedXp = 0;
  int _earnedCoins = 0;
  int _earnedGems = 0;
  int _earnedWoodLogs = 0;
  String? _pendingConstructionLevelId;

  // Getters
  PlayerModel get player => _player;
  List<WorldModel> get worlds => _worlds;
  List<AchievementModel> get achievements => _achievements;
  List<ShopItemModel> get shopItems => _shopItems;

  bool get isLoading => _isLoading;
  int get currentTab => _currentTab;
  bool get isTestMode => _isTestMode;

  LevelModel? get activeLevel => _activeLevel;
  int get currentQuestionIndex => _currentQuestionIndex;
  QuestionModel? get currentQuestion =>
      (_activeLevel != null &&
          _currentQuestionIndex < _activeLevel!.questions.length)
      ? _activeLevel!.questions[_currentQuestionIndex]
      : null;
  int? get selectedAnswerIndex => _selectedAnswerIndex;
  bool get isAnswerSubmitted => _isAnswerSubmitted;
  bool get isCorrectAnswer => _isCorrectAnswer;
  int get levelCorrectCount => _levelCorrectCount;
  int get levelHeartsLeft => _levelHeartsLeft;
  int get hintsUsedInLevel => _hintsUsedInLevel;
  bool get showExplanation => _showExplanation;

  bool get isLevelCompleted => _isLevelCompleted;
  bool get didPassLevel => _didPassLevel;
  int get earnedStars => _earnedStars;
  int get earnedXp => _earnedXp;
  int get earnedCoins => _earnedCoins;
  int get earnedGems => _earnedGems;
  int get earnedWoodLogs => _earnedWoodLogs;
  String? get pendingConstructionLevelId => _pendingConstructionLevelId;

  bool get canClaimDailyReward => _cooldownReady(_player.lastDailyRewardAt);
  bool get canClaimDailyChest => _cooldownReady(_player.lastDailyChestAt);

  bool _cooldownReady(String lastClaimedAt) {
    if (lastClaimedAt.isEmpty) return true;
    final lastClaim = DateTime.tryParse(lastClaimedAt);
    if (lastClaim == null) return true;
    return DateTime.now().difference(lastClaim) >= const Duration(hours: 24);
  }

  void clearPendingConstruction() {
    _pendingConstructionLevelId = null;
    notifyListeners();
  }

  int levelHouseStage(LevelModel level) {
    final canonicalStage = _player.buildingStages['hut_${level.id}'] ?? 0;
    if (level.worldId != 'world_1') {
      return canonicalStage.clamp(0, levelHouseFinalStage);
    }

    final legacyStage =
        _player.buildingStages['hut_level_${level.levelNumber}'] ?? 0;
    final savedStage = canonicalStage > legacyStage
        ? canonicalStage
        : legacyStage;
    return savedStage.clamp(0, levelHouseFinalStage);
  }

  bool isLevelHouseComplete(LevelModel level) =>
      levelHouseStage(level) >= levelHouseFinalStage;

  bool supportsLevelBuilding(LevelModel level) =>
      level.worldId == 'world_1' ||
      (level.worldId == 'world_2' &&
          level.levelNumber >= 6 &&
          level.levelNumber <= 10) ||
      (level.worldId == 'world_3' &&
          level.levelNumber >= 11 &&
          level.levelNumber <= 15);

  bool advanceLevelHouseConstruction(LevelModel level) {
    if (!supportsLevelBuilding(level) ||
        !_player.completedLevelIds.contains(level.id) ||
        _player.woodLogs <= 0) {
      return false;
    }

    final currentStage = levelHouseStage(level);
    if (currentStage >= levelHouseFinalStage) return false;

    final newBuildingStages = Map<String, int>.from(_player.buildingStages);
    newBuildingStages['hut_${level.id}'] = currentStage + 1;

    _player = _player.copyWith(
      woodLogs: _player.woodLogs - 1,
      buildingStages: newBuildingStages,
    );

    saveProgress();
    notifyListeners();
    return true;
  }

  GameProvider() {
    _initGame();
  }

  Future<void> _initGame() async {
    _isLoading = true;
    notifyListeners();

    _worlds = WorldRepository.getAllWorlds();
    _achievements = AchievementsRepository.getDefaultAchievements();
    _shopItems = ShopRepository.getDefaultShopItems();

    try {
      final prefs = await SharedPreferences.getInstance();
      final playerJson = prefs.getString('player_data');
      if (playerJson != null) {
        _player = PlayerModel.deserialize(playerJson);
      } else {
        _player = const PlayerModel();
      }
    } catch (e) {
      _player = const PlayerModel();
    }

    // Keep saved progress only for worlds represented on the illustrated map.
    final validLevelIds = _worlds
        .expand((world) => world.levels)
        .map((level) => level.id)
        .toSet();
    final cleanedCompletedLevels = _player.completedLevelIds.intersection(
      validLevelIds,
    );
    final cleanedLevelStars = Map<String, int>.fromEntries(
      _player.levelStars.entries.where(
        (entry) => validLevelIds.contains(entry.key),
      ),
    );
    final cleanedTotalStars = cleanedLevelStars.values.fold(
      0,
      (sum, stars) => sum + stars,
    );
    final Set<String> cleanedUnlockedWorlds = {'world_1'};
    for (final world in _worlds.skip(1)) {
      if (cleanedTotalStars >= world.reqStarsToUnlock) {
        cleanedUnlockedWorlds.add(world.id);
      }
    }
    _player = _player.copyWith(
      completedLevelIds: cleanedCompletedLevels,
      levelStars: cleanedLevelStars,
      unlockedWorldIds: cleanedUnlockedWorlds,
      perfectLevelIds: _player.perfectLevelIds.intersection(validLevelIds),
    );

    _normalizeStreakOnLoad();
    _updateAchievementsProgress();
    await saveProgress();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('player_data', _player.serialize());
    } catch (e) {
      debugPrint('Error saving progress: $e');
    }
  }

  void setCurrentTab(int index) {
    _currentTab = index;
    notifyListeners();
  }

  void _normalizeStreakOnLoad() {
    if (_player.lastPlayDate.isEmpty) return;
    final lastDate = DateTime.tryParse(_player.lastPlayDate);
    if (lastDate == null || DateTime.now().difference(lastDate).inDays > 1) {
      _player = _player.copyWith(streakDays: 0);
    }
  }

  void _recordQuestCompletionToday() {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    if (_player.lastPlayDate == today) return;

    final lastDate = DateTime.tryParse(_player.lastPlayDate);
    final isConsecutive =
        lastDate != null &&
        DateTime.parse(today).difference(lastDate).inDays == 1;
    _player = _player.copyWith(
      streakDays: isConsecutive ? _player.streakDays + 1 : 1,
      lastPlayDate: today,
    );
  }

  void updatePlayerName(String name) {
    if (name.trim().isEmpty) return;
    _player = _player.copyWith(name: name.trim());
    saveProgress();
    notifyListeners();
  }

  void toggleHaptics() {
    _player = _player.copyWith(isHapticsEnabled: !_player.isHapticsEnabled);
    saveProgress();
    notifyListeners();
  }

  void toggleAutoShowExplanations() {
    _player = _player.copyWith(
      autoShowExplanations: !_player.autoShowExplanations,
    );
    saveProgress();
    notifyListeners();
  }

  Future<void> resetGameProgress() async {
    _player = const PlayerModel();
    _currentTab = 1;
    _activeLevel = null;
    _isLevelCompleted = false;
    _didPassLevel = false;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('player_data');
    } catch (e) {
      debugPrint('Error clearing player prefs: $e');
    }

    await saveProgress();
    notifyListeners();
  }

  Future<void> updatePlayerAvatar({
    String? name,
    String? avatarId,
    String? hatId,
  }) async {
    final supportedAvatarId = avatarId == 'hero_boy' ? 'hero_wizard' : avatarId;
    _player = _player.copyWith(
      name: name ?? _player.name,
      avatarId: supportedAvatarId ?? _player.avatarId,
      equippedHatId: hatId ?? _player.equippedHatId,
      onboardingCompleted: true,
    );
    await saveProgress();
    notifyListeners();
  }

  // GAMEPLAY LIFECYCLE
  void startLevel(LevelModel level) {
    _startLevelSession(level, testMode: false);
  }

  void startTestLevel(LevelModel level) {
    _startLevelSession(level, testMode: true);
  }

  void restartActiveLevel() {
    final level = _activeLevel;
    if (level == null) return;
    _startLevelSession(level, testMode: _isTestMode);
  }

  void endTestSession() {
    if (!_isTestMode) return;
    _isTestMode = false;
    _activeLevel = null;
    _isLevelCompleted = false;
    _didPassLevel = false;
    _showExplanation = false;
    notifyListeners();
  }

  void _startLevelSession(LevelModel level, {required bool testMode}) {
    _isTestMode = testMode;
    _activeLevel = level;
    _currentQuestionIndex = 0;
    _selectedAnswerIndex = null;
    _isAnswerSubmitted = false;
    _isCorrectAnswer = false;
    _levelCorrectCount = 0;
    _levelHeartsLeft = 3;
    _hintsUsedInLevel = 0;
    _showExplanation = false;
    _isLevelCompleted = false;
    _didPassLevel = false;
    _earnedStars = 0;
    _earnedXp = 0;
    _earnedCoins = 0;
    _earnedGems = 0;
    _earnedWoodLogs = 0;

    notifyListeners();
  }

  void selectAnswer(int index) {
    if (_isAnswerSubmitted || _isLevelCompleted || _levelHeartsLeft <= 0) {
      return;
    }
    _selectedAnswerIndex = index;
    notifyListeners();
  }

  void submitAnswer() {
    if (_selectedAnswerIndex == null ||
        _isAnswerSubmitted ||
        _isLevelCompleted ||
        _levelHeartsLeft <= 0 ||
        currentQuestion == null) {
      return;
    }

    _isAnswerSubmitted = true;
    _isCorrectAnswer =
        (_selectedAnswerIndex == currentQuestion!.correctAnswerIndex);

    final updatedSolved = _player.questionsSolved + 1;
    final updatedCorrect = _isCorrectAnswer
        ? _player.correctAnswers + 1
        : _player.correctAnswers;

    if (_isCorrectAnswer) {
      _levelCorrectCount++;
      _earnedXp += currentQuestion!.xpReward;
      _earnedCoins += currentQuestion!.coinReward;
      _earnedGems += currentQuestion!.gemReward;

      if (!_isTestMode) {
        _player = _player.copyWith(
          questionsSolved: updatedSolved,
          correctAnswers: updatedCorrect,
        );
      }
    } else {
      _levelHeartsLeft--;
      _showExplanation = true;
      if (!_isTestMode) {
        _player = _player.copyWith(
          questionsSolved: updatedSolved,
          correctAnswers: updatedCorrect,
        );
      }
    }

    if (!_isTestMode) saveProgress();
    notifyListeners();
  }

  void closeExplanation() {
    _showExplanation = false;
    notifyListeners();
  }

  void nextQuestion() {
    if (_activeLevel == null || !_isAnswerSubmitted || _isLevelCompleted) {
      return;
    }

    _selectedAnswerIndex = null;
    _isAnswerSubmitted = false;
    _isCorrectAnswer = false;
    _showExplanation = false;

    if (_currentQuestionIndex + 1 < _activeLevel!.questions.length) {
      _currentQuestionIndex++;
    } else {
      _finishLevel();
    }
    notifyListeners();
  }

  // HINT SYSTEM (INSTANTLY DEDUCTS 3 GEMS & SAVES STATE)
  bool useHint() {
    if (currentQuestion == null || _isAnswerSubmitted || _isLevelCompleted) {
      return false;
    }
    if (_isTestMode) {
      _hintsUsedInLevel++;
      notifyListeners();
      return true;
    }
    if (_player.gems < 3) return false;
    final newGems = _player.gems - 3;
    _player = _player.copyWith(gems: newGems);
    _hintsUsedInLevel++;
    saveProgress();
    notifyListeners();
    return true;
  }

  // REVIVE SYSTEM (INSTANTLY DEDUCTS 5 GEMS)
  bool reviveLevelWithGems() {
    if (_levelHeartsLeft > 0 || _isLevelCompleted) return false;
    if (_isTestMode) {
      _levelHeartsLeft = 3;
      notifyListeners();
      return true;
    }
    if (_player.gems < 5) return false;
    _player = _player.copyWith(gems: _player.gems - 5);
    _levelHeartsLeft = 3;
    saveProgress();
    notifyListeners();
    return true;
  }

  // REWARDED AD SYSTEM (+5 FREE GEMS)
  void watchAdForGems() {
    _player = _player.copyWith(gems: _player.gems + 5);
    saveProgress();
    notifyListeners();
  }

  bool claimDailyReward(int coinAmount) {
    if (!canClaimDailyReward) return false;
    _player = _player.copyWith(
      coins: _player.coins + coinAmount,
      lifetimeCoinsEarned: _player.lifetimeCoinsEarned + coinAmount,
      lastDailyRewardAt: DateTime.now().toIso8601String(),
    );
    _updateAchievementsProgress();
    saveProgress();
    notifyListeners();
    return true;
  }

  bool claimDailyChest(int coinAmount) {
    if (!canClaimDailyChest) return false;
    _player = _player.copyWith(
      coins: _player.coins + coinAmount,
      lifetimeCoinsEarned: _player.lifetimeCoinsEarned + coinAmount,
      lastDailyChestAt: DateTime.now().toIso8601String(),
    );
    _updateAchievementsProgress();
    saveProgress();
    notifyListeners();
    return true;
  }

  void _finishLevel() {
    if (_activeLevel == null) return;

    final totalQuestions = _activeLevel!.questions.length;
    final ratio = _levelCorrectCount / totalQuestions;

    if (ratio >= 0.9) {
      _earnedStars = 3;
    } else if (ratio >= 0.6) {
      _earnedStars = 2;
    } else if (ratio > 0) {
      _earnedStars = 1;
    } else {
      _earnedStars = 0;
    }

    _didPassLevel = ratio >= 0.6;
    if (!_didPassLevel) {
      _earnedStars = 0;
    }

    if (_isTestMode) {
      _isLevelCompleted = true;
      notifyListeners();
      return;
    }

    if (!_didPassLevel) {
      _earnedXp = 0;
      _earnedCoins = 0;
      _earnedGems = 0;
      _earnedWoodLogs = 0;
      _pendingConstructionLevelId = null;
      _isLevelCompleted = true;
      saveProgress();
      notifyListeners();
      return;
    }

    final newLevelStars = Map<String, int>.from(_player.levelStars);
    final previousStars = newLevelStars[_activeLevel!.id] ?? 0;
    if (_earnedStars > previousStars) {
      newLevelStars[_activeLevel!.id] = _earnedStars;
    }

    final newCompletedLevels = Set<String>.from(_player.completedLevelIds);
    final isFirstCompletion = !newCompletedLevels.contains(_activeLevel!.id);
    newCompletedLevels.add(_activeLevel!.id);

    final newUnlockedWorlds = Set<String>.from(_player.unlockedWorldIds);
    final newTotalStars = newLevelStars.values.fold(
      0,
      (sum, stars) => sum + stars,
    );

    for (final world in _worlds.skip(1)) {
      if (newTotalStars >= world.reqStarsToUnlock) {
        newUnlockedWorlds.add(world.id);
      }
    }

    final newPerfectLevelIds = Set<String>.from(_player.perfectLevelIds);
    if (_earnedStars == 3) {
      newPerfectLevelIds.add(_activeLevel!.id);
    }

    if (isFirstCompletion) {
      _earnedCoins += 30 + (_earnedStars * 10);
      _earnedGems += _earnedStars == 3 ? 3 : 1;
      _earnedWoodLogs = 2 + _earnedStars;
      _earnedXp += 50 + (_earnedStars * 20);
    } else {
      _earnedXp = 0;
      _earnedCoins = 0;
      _earnedGems = 0;
      _earnedWoodLogs = 0;
    }
    _recordQuestCompletionToday();

    int newCurrentXp = _player.currentXp + _earnedXp;
    int newLevel = _player.level;
    int newTotalXp = _player.totalXp + _earnedXp;

    while (newCurrentXp >= (newLevel * 100)) {
      newCurrentXp -= (newLevel * 100);
      newLevel++;
    }

    _player = _player.copyWith(
      level: newLevel,
      currentXp: newCurrentXp,
      totalXp: newTotalXp,
      coins: _player.coins + _earnedCoins,
      gems: _player.gems + _earnedGems,
      woodLogs: _player.woodLogs + _earnedWoodLogs,
      levelStars: newLevelStars,
      completedLevelIds: newCompletedLevels,
      unlockedWorldIds: newUnlockedWorlds,
      perfectLevelIds: newPerfectLevelIds,
      lifetimeCoinsEarned: _player.lifetimeCoinsEarned + _earnedCoins,
    );

    _isLevelCompleted = true;
    _pendingConstructionLevelId = isFirstCompletion ? _activeLevel!.id : null;
    _updateAchievementsProgress();
    saveProgress();
    notifyListeners();
  }

  void _updateAchievementsProgress() {
    final updatedList = <AchievementModel>[];

    for (final ach in _achievements) {
      double currentProgress = 0;

      switch (ach.id) {
        case 'ach_first_quest':
          currentProgress = _player.completedLevelIds.isNotEmpty ? 1 : 0;
          break;
        case 'ach_math_wizard':
          currentProgress = _player.totalStars.toDouble();
          break;
        case 'ach_streak_master':
          currentProgress = _player.streakDays.toDouble();
          break;
        case 'ach_no_mistakes':
          currentProgress = _player.perfectLevelIds.isNotEmpty ? 1 : 0;
          break;
        case 'ach_world_explorer':
          currentProgress = _player.unlockedWorldIds.contains('world_2')
              ? 1
              : 0;
          break;
        case 'ach_double_digit_hero':
          currentProgress = _player.completedLevelIds
              .where((levelId) => levelId.startsWith('w2_'))
              .length
              .toDouble();
          break;
        case 'ach_coin_collector':
          currentProgress = _player.lifetimeCoinsEarned.toDouble();
          break;
        default:
          currentProgress = ach.currentProgress;
      }

      updatedList.add(
        ach.copyWith(
          currentProgress: currentProgress,
          isClaimed: _player.claimedAchievementIds.contains(ach.id),
        ),
      );
    }

    _achievements = updatedList;
  }

  void claimAchievementReward(String achievementId) {
    final index = _achievements.indexWhere((a) => a.id == achievementId);
    if (index != -1 &&
        _achievements[index].isCompleted &&
        !_achievements[index].isClaimed) {
      final ach = _achievements[index];
      final claimedIds = Set<String>.from(_player.claimedAchievementIds)
        ..add(ach.id);

      _player = _player.copyWith(
        coins: _player.coins + ach.rewardCoins,
        gems: _player.gems + ach.rewardGems,
        lifetimeCoinsEarned: _player.lifetimeCoinsEarned + ach.rewardCoins,
        claimedAchievementIds: claimedIds,
      );

      _achievements[index] = ach.copyWith(isClaimed: true);
      _updateAchievementsProgress();
      saveProgress();
      notifyListeners();
    }
  }

  void purchaseShopItem(ShopItemModel item) {
    if (_player.inventoryItemIds.contains(item.id)) return;
    if (item.currency == CurrencyType.coins && _player.coins < item.price) {
      return;
    }
    if (item.currency == CurrencyType.gems && _player.gems < item.price) {
      return;
    }

    final newCoins = item.currency == CurrencyType.coins
        ? _player.coins - item.price
        : _player.coins;
    final newGems = item.currency == CurrencyType.gems
        ? _player.gems - item.price
        : _player.gems;

    final newInventory = List<String>.from(_player.inventoryItemIds)
      ..add(item.id);

    _player = _player.copyWith(
      coins: newCoins,
      gems: newGems,
      inventoryItemIds: newInventory,
    );

    final idx = _shopItems.indexWhere((s) => s.id == item.id);
    if (idx != -1) {
      _shopItems[idx] = _shopItems[idx].copyWith(isUnlocked: true);
    }

    saveProgress();
    notifyListeners();
  }

  void equipShopItem(ShopItemModel item) {
    if (!_player.inventoryItemIds.contains(item.id)) return;

    _player = _player.copyWith(equippedHatId: item.id);

    _shopItems = _shopItems.map((s) {
      if (s.category == item.category) {
        return s.copyWith(isEquipped: s.id == item.id);
      }
      return s;
    }).toList();

    saveProgress();
    notifyListeners();
  }

  bool isLevelUnlocked(LevelModel level) {
    if (level.id == 'w1_l1' || level.levelNumber == 1) {
      return true;
    }

    if (_player.completedLevelIds.contains(level.id)) {
      return true;
    }

    if (!_player.unlockedWorldIds.contains(level.worldId)) {
      return false;
    }

    if (_player.totalStars < level.reqStarsToUnlock) {
      return false;
    }

    final world = _worlds.firstWhere(
      (w) => w.id == level.worldId,
      orElse: () => _worlds.first,
    );
    final index = world.levels.indexWhere((l) => l.id == level.id);
    if (index < 0) return false;

    if (index == 0) {
      return true;
    }

    final previousLevel = world.levels[index - 1];
    return _player.completedLevelIds.contains(previousLevel.id);
  }
}
