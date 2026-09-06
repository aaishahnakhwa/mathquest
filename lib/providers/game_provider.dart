import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/player_model.dart';
import '../models/world_model.dart';
import '../models/level_model.dart';
import '../models/question_model.dart';
import '../models/achievement_model.dart';
import '../models/shop_model.dart';
import '../models/building_model.dart';
import '../data/world_repository.dart';
import '../data/achievements_repository.dart';
import '../data/shop_repository.dart';
import '../data/village_repository.dart';

class GameProvider extends ChangeNotifier {
  PlayerModel _player = const PlayerModel();
  List<WorldModel> _worlds = [];
  List<AchievementModel> _achievements = [];
  List<ShopItemModel> _shopItems = [];
  List<BuildingModel> _buildings = [];

  bool _isLoading = true;
  int _currentTab = 1; // Default tab: Map

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
  List<BuildingModel> get buildings => _buildings;

  List<BuildingModel> get activeBuildings {
    return _buildings.map((b) {
      final currentStage = _player.buildingStages[b.id] ?? 0;
      return b.copyWith(currentStage: currentStage);
    }).toList();
  }

  bool get isLoading => _isLoading;
  int get currentTab => _currentTab;

  LevelModel? get activeLevel => _activeLevel;
  int get currentQuestionIndex => _currentQuestionIndex;
  QuestionModel? get currentQuestion =>
      (_activeLevel != null && _currentQuestionIndex < _activeLevel!.questions.length)
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
  int get earnedStars => _earnedStars;
  int get earnedXp => _earnedXp;
  int get earnedCoins => _earnedCoins;
  int get earnedGems => _earnedGems;
  int get earnedWoodLogs => _earnedWoodLogs;
  String? get pendingConstructionLevelId => _pendingConstructionLevelId;

  void clearPendingConstruction() {
    _pendingConstructionLevelId = null;
    notifyListeners();
  }

  bool upgradeBuilding(String buildingId) {
    final buildingList = activeBuildings;
    final index = buildingList.indexWhere((b) => b.id == buildingId);
    if (index == -1) return false;

    final building = buildingList[index];
    if (building.isMaxStage) return false;

    final coinCost = building.nextStageCoinCost;
    final woodCost = building.nextStageWoodCost;

    if (_player.coins < coinCost || _player.woodLogs < woodCost) {
      return false;
    }

    final newBuildingStages = Map<String, int>.from(_player.buildingStages);
    newBuildingStages[buildingId] = building.currentStage + 1;

    _player = _player.copyWith(
      coins: _player.coins - coinCost,
      woodLogs: _player.woodLogs - woodCost,
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
    _buildings = VillageRepository.getDefaultBuildings();

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

    final hasCompletedW1 = _player.completedLevelIds.contains('w1_l5') || _player.totalStars >= 10;
    final Set<String> cleanedUnlockedWorlds = {'world_1'};
    if (hasCompletedW1) {
      cleanedUnlockedWorlds.add('world_2');
    }
    _player = _player.copyWith(unlockedWorldIds: cleanedUnlockedWorlds);

    _updateStreakOnLoad();
    _updateAchievementsProgress();

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

  void _updateStreakOnLoad() {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    if (_player.lastPlayDate.isEmpty) {
      _player = _player.copyWith(lastPlayDate: today, streakDays: 1);
    } else if (_player.lastPlayDate != today) {
      final lastDate = DateTime.parse(_player.lastPlayDate);
      final difference = DateTime.now().difference(lastDate).inDays;
      if (difference == 1) {
        _player = _player.copyWith(
          streakDays: _player.streakDays + 1,
          lastPlayDate: today,
        );
      } else if (difference > 1) {
        _player = _player.copyWith(streakDays: 1, lastPlayDate: today);
      }
    }
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
    _player =
        _player.copyWith(autoShowExplanations: !_player.autoShowExplanations);
    saveProgress();
    notifyListeners();
  }

  Future<void> resetGameProgress() async {
    _player = const PlayerModel();
    _currentTab = 1;
    _activeLevel = null;
    _isLevelCompleted = false;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('player_data');
    } catch (e) {
      debugPrint('Error clearing player prefs: $e');
    }

    saveProgress();
    notifyListeners();
  }

  void updatePlayerAvatar({
    String? name,
    String? avatarId,
    String? hatId,
    String? outfitId,
    String? accessoryId,
  }) {
    _player = _player.copyWith(
      name: name ?? _player.name,
      avatarId: avatarId ?? _player.avatarId,
      equippedHatId: hatId ?? _player.equippedHatId,
      equippedOutfitId: outfitId ?? _player.equippedOutfitId,
      equippedAccessoryId: accessoryId ?? _player.equippedAccessoryId,
    );
    saveProgress();
    notifyListeners();
  }

  // GAMEPLAY LIFECYCLE
  void startLevel(LevelModel level) {
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
    _earnedStars = 0;
    _earnedXp = 0;
    _earnedCoins = 0;
    _earnedGems = 0;
    _earnedWoodLogs = 0;

    notifyListeners();
  }

  void selectAnswer(int index) {
    if (_isAnswerSubmitted) return;
    _selectedAnswerIndex = index;
    notifyListeners();
  }

  void submitAnswer() {
    if (_selectedAnswerIndex == null || _isAnswerSubmitted || currentQuestion == null) {
      return;
    }

    _isAnswerSubmitted = true;
    _isCorrectAnswer = (_selectedAnswerIndex == currentQuestion!.correctAnswerIndex);

    final updatedSolved = _player.questionsSolved + 1;
    final updatedCorrect =
        _isCorrectAnswer ? _player.correctAnswers + 1 : _player.correctAnswers;

    if (_isCorrectAnswer) {
      _levelCorrectCount++;
      _earnedXp += currentQuestion!.xpReward;
      _earnedCoins += currentQuestion!.coinReward;
      _earnedGems += currentQuestion!.gemReward;

      _player = _player.copyWith(
        questionsSolved: updatedSolved,
        correctAnswers: updatedCorrect,
        coins: _player.coins + currentQuestion!.coinReward,
        gems: _player.gems + currentQuestion!.gemReward,
      );
    } else {
      _levelHeartsLeft--;
      _showExplanation = true;
      _player = _player.copyWith(
        questionsSolved: updatedSolved,
        correctAnswers: updatedCorrect,
      );
    }

    saveProgress();
    notifyListeners();
  }

  void closeExplanation() {
    _showExplanation = false;
    notifyListeners();
  }

  void nextQuestion() {
    if (_activeLevel == null) return;

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
    if (_player.gems < 3 || currentQuestion == null) {
      return false;
    }
    final newGems = _player.gems - 3;
    _player = _player.copyWith(gems: newGems);
    _hintsUsedInLevel++;
    saveProgress();
    notifyListeners();
    return true;
  }

  // REVIVE SYSTEM (INSTANTLY DEDUCTS 5 GEMS)
  bool reviveLevelWithGems() {
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

  void claimDailyReward(int coinAmount) {
    _player = _player.copyWith(coins: _player.coins + coinAmount);
    saveProgress();
    notifyListeners();
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

    final levelBonusGems = _earnedStars == 3 ? 3 : 1;
    final levelBonusCoins = 30 + (_earnedStars * 10);
    _earnedWoodLogs = 2 + (_earnedStars * 1); // 2 to 5 Wood Logs per level!
    _earnedXp += 50 + (_earnedStars * 20);

    final newLevelStars = Map<String, int>.from(_player.levelStars);
    final previousStars = newLevelStars[_activeLevel!.id] ?? 0;
    if (_earnedStars > previousStars) {
      newLevelStars[_activeLevel!.id] = _earnedStars;
    }

    final newCompletedLevels = Set<String>.from(_player.completedLevelIds);
    newCompletedLevels.add(_activeLevel!.id);

    final newUnlockedWorlds = Set<String>.from(_player.unlockedWorldIds);
    final newTotalStars =
        newLevelStars.values.fold(0, (sum, stars) => sum + stars);

    if (newTotalStars >= 10 || newCompletedLevels.contains('w1_l5')) {
      newUnlockedWorlds.add('world_2');
    }
    if (newTotalStars >= 25) {
      newUnlockedWorlds.add('world_3');
    }
    if (newTotalStars >= 40) {
      newUnlockedWorlds.add('world_4');
    }

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
      coins: _player.coins + levelBonusCoins,
      gems: _player.gems + levelBonusGems,
      woodLogs: _player.woodLogs + _earnedWoodLogs,
      levelStars: newLevelStars,
      completedLevelIds: newCompletedLevels,
      unlockedWorldIds: newUnlockedWorlds,
    );

    _isLevelCompleted = true;
    _pendingConstructionLevelId = _activeLevel!.id;
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
          currentProgress = (_earnedStars == 3 && _isLevelCompleted) ? 1 : 0;
          break;
        case 'ach_world_explorer':
          currentProgress = _player.unlockedWorldIds.contains('world_2') ? 1 : 0;
          break;
        case 'ach_fraction_hero':
          currentProgress = _player.correctAnswers.toDouble();
          break;
        case 'ach_coin_collector':
          currentProgress = _player.coins.toDouble();
          break;
        default:
          currentProgress = ach.currentProgress;
      }

      updatedList.add(ach.copyWith(currentProgress: currentProgress));
    }

    _achievements = updatedList;
  }

  void claimAchievementReward(String achievementId) {
    final index = _achievements.indexWhere((a) => a.id == achievementId);
    if (index != -1 &&
        _achievements[index].isCompleted &&
        !_achievements[index].isClaimed) {
      final ach = _achievements[index];

      _player = _player.copyWith(
        coins: _player.coins + ach.rewardCoins,
        gems: _player.gems + ach.rewardGems,
      );

      _achievements[index] = ach.copyWith(isClaimed: true);
      saveProgress();
      notifyListeners();
    }
  }

  void purchaseShopItem(ShopItemModel item) {
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

    if (item.category == ShopCategory.avatarHat) {
      _player = _player.copyWith(equippedHatId: item.id);
    } else if (item.category == ShopCategory.avatarOutfit) {
      _player = _player.copyWith(equippedOutfitId: item.id);
    } else if (item.category == ShopCategory.accessory) {
      _player = _player.copyWith(equippedAccessoryId: item.id);
    }

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

    if (!_player.unlockedWorldIds.contains(level.worldId)) {
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
    return _player.completedLevelIds.contains(previousLevel.id) ||
        _player.completedLevelIds.contains(level.id);
  }
}
