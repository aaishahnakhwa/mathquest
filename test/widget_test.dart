import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;
import 'package:math_quest/main.dart';
import 'package:math_quest/data/level_cheat_codes.dart';
import 'package:math_quest/data/world_repository.dart';
import 'package:math_quest/models/monster_model.dart';
import 'package:math_quest/models/level_model.dart';
import 'package:math_quest/models/player_model.dart';
import 'package:math_quest/providers/game_provider.dart';
import 'package:math_quest/screens/adventure_map_screen.dart';
import 'package:math_quest/screens/foundation_builder_screen.dart';
import 'package:math_quest/screens/gameplay_screen.dart';
import 'package:math_quest/screens/onboarding_screen.dart';
import 'package:math_quest/widgets/ambient_butterfly.dart';
import 'package:math_quest/widgets/ambient_leaf_field.dart';
import 'package:math_quest/widgets/avatar_widget.dart';
import 'package:math_quest/widgets/battle_arena_widget.dart';
import 'package:math_quest/widgets/level_node_widget.dart';
import 'package:math_quest/widgets/village_buildings_overlay.dart';
import 'package:math_quest/widgets/world_three_lumina_field.dart';
import 'package:math_quest/widgets/world_two_icy_wind_overlay.dart';
import 'package:math_quest/widgets/world_two_snow_overlay.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('world repository exposes the three illustrated map worlds', () {
    final worlds = WorldRepository.getAllWorlds();

    expect(worlds.map((world) => world.id), ['world_1', 'world_2', 'world_3']);
    expect(worlds.expand((world) => world.levels), hasLength(15));
    expect(
      worlds
          .expand((world) => world.levels)
          .map((level) => level.worldId)
          .toSet(),
      {'world_1', 'world_2', 'world_3'},
    );
  });

  test('World 2 provides a complete five-level integer challenge', () {
    final world = WorldRepository.getAllWorlds().firstWhere(
      (candidate) => candidate.id == 'world_2',
    );
    final questions = world.levels.expand((level) => level.questions).toList();

    expect(world.levels.map((level) => level.levelNumber), [6, 7, 8, 9, 10]);
    expect(world.levels.every((level) => level.questions.length == 5), isTrue);
    expect(questions.map((question) => question.id).toSet(), hasLength(25));
    for (final question in questions) {
      expect(question.options, hasLength(4));
      expect(question.correctAnswerIndex, inInclusiveRange(0, 3));
      expect(question.explanationSteps, isNotEmpty);
      expect(question.hintText, isNotEmpty);
    }
  });

  test('World 3 stays within a gradual five-level pre-algebra path', () {
    final world = WorldRepository.getAllWorlds().last;
    final questions = world.levels.expand((level) => level.questions).toList();

    expect(world.subtitle, 'A Gentle Pre-Algebra Journey');
    expect(world.levels.map((level) => level.title), [
      'Integer Trail',
      'Fraction Grove',
      'Ratio River',
      'Equation Climb',
      'Pre-Algebra Review',
    ]);
    expect(world.levels.every((level) => level.questions.length == 5), isTrue);
    expect(questions, hasLength(25));
    expect(questions.map((question) => question.id).toSet(), hasLength(25));
    expect(
      questions.any((question) => question.difficulty == 'Advanced'),
      isFalse,
    );
    for (final question in questions) {
      expect(question.options, hasLength(4));
      expect(question.options.toSet(), hasLength(4));
      expect(question.correctAnswerIndex, inInclusiveRange(0, 3));
      expect(question.explanationSteps, isNotEmpty);
      expect(question.hintText, isNotEmpty);
    }
  });

  test(
    'level unlocks require both stars and previous-level completion',
    () async {
      final level = WorldRepository.getAllWorlds().first.levels[1];

      for (final stars in [0, 1]) {
        final player = PlayerModel(
          completedLevelIds: const {'w1_l1'},
          levelStars: {'w1_l1': stars},
        );
        SharedPreferences.setMockInitialValues({
          'player_data': player.serialize(),
        });
        final provider = GameProvider();
        while (provider.isLoading) {
          await Future<void>.delayed(Duration.zero);
        }

        expect(
          provider.isLevelUnlocked(level),
          stars >= level.reqStarsToUnlock,
        );
        provider.dispose();
      }
    },
  );

  test('failed level grants no rewards, completion, or construction', () async {
    SharedPreferences.setMockInitialValues({});
    final provider = GameProvider();
    while (provider.isLoading) {
      await Future<void>.delayed(Duration.zero);
    }
    final level = provider.worlds.first.levels.first;
    final before = provider.player;
    provider.startLevel(level);

    while (!provider.isLevelCompleted) {
      final question = provider.currentQuestion!;
      provider.selectAnswer((question.correctAnswerIndex + 1) % 4);
      provider.submitAnswer();
      if (provider.levelHeartsLeft <= 0) {
        expect(provider.reviveLevelWithGems(), isTrue);
      }
      provider.nextQuestion();
    }

    expect(provider.didPassLevel, isFalse);
    expect(provider.earnedStars, 0);
    expect(provider.earnedCoins, 0);
    expect(provider.earnedGems, 0);
    expect(provider.earnedXp, 0);
    expect(provider.earnedWoodLogs, 0);
    expect(provider.player.coins, before.coins);
    expect(provider.player.gems, before.gems - 5);
    expect(provider.player.completedLevelIds, isNot(contains(level.id)));
    expect(provider.pendingConstructionLevelId, isNull);
    provider.dispose();
  });

  test('retries cannot farm rewards from an already completed level', () async {
    SharedPreferences.setMockInitialValues({});
    final provider = GameProvider();
    while (provider.isLoading) {
      await Future<void>.delayed(Duration.zero);
    }
    final level = provider.worlds.first.levels.first;
    provider.startLevel(level);
    while (!provider.isLevelCompleted) {
      provider.selectAnswer(provider.currentQuestion!.correctAnswerIndex);
      provider.submitAnswer();
      provider.nextQuestion();
    }
    expect(provider.earnedCoins, provider.player.coins - 100);
    expect(provider.earnedGems, provider.player.gems - 5);
    expect(provider.earnedXp, provider.player.totalXp);
    final coinsAfterFirstCompletion = provider.player.coins;
    final gemsAfterFirstCompletion = provider.player.gems;
    final xpAfterFirstCompletion = provider.player.totalXp;

    provider.startLevel(level);
    provider.selectAnswer(provider.currentQuestion!.correctAnswerIndex);
    provider.submitAnswer();
    expect(provider.player.coins, coinsAfterFirstCompletion);
    expect(provider.player.gems, gemsAfterFirstCompletion);
    while (!provider.isLevelCompleted) {
      if (!provider.isAnswerSubmitted) {
        provider.selectAnswer(provider.currentQuestion!.correctAnswerIndex);
        provider.submitAnswer();
      }
      provider.nextQuestion();
    }

    expect(provider.didPassLevel, isTrue);
    expect(provider.earnedCoins, 0);
    expect(provider.earnedGems, 0);
    expect(provider.earnedXp, 0);
    expect(provider.player.coins, coinsAfterFirstCompletion);
    expect(provider.player.gems, gemsAfterFirstCompletion);
    expect(provider.player.totalXp, xpAfterFirstCompletion);
    provider.dispose();
  });

  test('daily rewards and achievement claims survive reloads', () async {
    final player = PlayerModel(
      levelStars: const {
        'w1_l1': 3,
        'w1_l2': 3,
        'w1_l3': 3,
        'w1_l4': 3,
        'w1_l5': 3,
      },
    );
    SharedPreferences.setMockInitialValues({'player_data': player.serialize()});
    final provider = GameProvider();
    while (provider.isLoading) {
      await Future<void>.delayed(Duration.zero);
    }

    expect(provider.claimDailyReward(50), isTrue);
    expect(provider.claimDailyReward(50), isFalse);
    expect(provider.claimDailyChest(100), isTrue);
    expect(provider.claimDailyChest(100), isFalse);
    provider.claimAchievementReward('ach_math_wizard');
    await provider.saveProgress();
    final balanceAfterClaims = provider.player.coins;
    provider.dispose();

    final reloaded = GameProvider();
    while (reloaded.isLoading) {
      await Future<void>.delayed(Duration.zero);
    }
    expect(reloaded.canClaimDailyReward, isFalse);
    expect(reloaded.canClaimDailyChest, isFalse);
    expect(reloaded.player.claimedAchievementIds, contains('ach_math_wizard'));
    reloaded.claimAchievementReward('ach_math_wizard');
    expect(reloaded.player.coins, balanceAfterClaims);
    reloaded.dispose();
  });

  test('onboarding completion and avatar choice survive reloads', () async {
    SharedPreferences.setMockInitialValues({});
    final provider = GameProvider();
    while (provider.isLoading) {
      await Future<void>.delayed(Duration.zero);
    }
    expect(provider.player.onboardingCompleted, isFalse);

    await provider.updatePlayerAvatar(
      name: 'Nova',
      avatarId: AvatarWidget.femaleWizardId,
    );
    provider.dispose();

    final reloaded = GameProvider();
    while (reloaded.isLoading) {
      await Future<void>.delayed(Duration.zero);
    }
    expect(reloaded.player.onboardingCompleted, isTrue);
    expect(reloaded.player.name, 'Nova');
    expect(reloaded.player.avatarId, AvatarWidget.femaleWizardId);
    reloaded.dispose();
  });

  test('legacy knight saves migrate to the male wizard', () {
    final player = PlayerModel.fromMap(const {'avatarId': 'hero_boy'});

    expect(player.avatarId, AvatarWidget.maleWizardId);
  });

  testWidgets('female wizard is available as an illustrated hero avatar', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AvatarWidget(avatarId: 'hero_girl', size: 100)),
      ),
    );

    expect(
      find.image(const AssetImage(AvatarWidget.femaleWizardAvatarAsset)),
      findsOneWidget,
    );

    final avatar = image.decodePng(
      File(AvatarWidget.femaleWizardAvatarAsset).readAsBytesSync(),
    );
    expect(avatar, isNotNull);
    expect(avatar!.width, 1254);
    expect(avatar.height, 1254);
  });

  testWidgets('female selection replaces the wizard on the adventure map', (
    tester,
  ) async {
    const level = LevelModel(
      id: 'w1_l1',
      worldId: 'world_1',
      levelNumber: 1,
      title: 'First Steps',
      topic: 'Addition',
      difficulty: 'Beginner',
      questions: [],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LevelNodeWidget(
            level: level,
            isUnlocked: true,
            isCompleted: false,
            isCurrent: true,
            earnedStars: 0,
            playerAvatarId: AvatarWidget.femaleWizardId,
            onTap: () {},
          ),
        ),
      ),
    );

    expect(
      find.image(const AssetImage(AvatarWidget.femaleWizardCharacterAsset)),
      findsOneWidget,
    );
    expect(
      find.image(const AssetImage(AvatarWidget.wizardCharacterAsset)),
      findsNothing,
    );
  });

  test('every playable level uses its matching transparent button asset', () {
    final levels = WorldRepository.getAllWorlds().expand(
      (world) => world.levels,
    );

    for (final level in levels) {
      final asset = LevelNodeWidget.buttonAssetForLevel(
        levelNumber: level.levelNumber,
        isUnlocked: true,
      );
      expect(asset, 'assets/images/level_btn_${level.levelNumber}.png');
      final file = File(asset);
      expect(file.existsSync(), isTrue, reason: 'Missing $asset');
      final sprite = image.decodePng(file.readAsBytesSync());
      expect(sprite, isNotNull, reason: 'Invalid PNG: $asset');
      if (level.levelNumber >= 12) {
        expect(
          sprite!.getPixel(0, 0).a,
          0,
          reason: '$asset is not transparent',
        );
      }
    }

    expect(
      LevelNodeWidget.buttonAssetForLevel(levelNumber: 15, isUnlocked: false),
      LevelNodeWidget.lockedButtonAsset,
    );
  });

  testWidgets('onboarding offers the female wizard choice', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: OnboardingScreen()));
    await tester.tap(find.text('CONTINUE'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Female Wizard'), findsOneWidget);
    await tester.tap(find.textContaining('Female Wizard'));
    await tester.pump();
    expect(
      find.image(const AssetImage(AvatarWidget.femaleWizardAvatarAsset)),
      findsNWidgets(2),
    );
  });

  test('World 2 uses its own snowy battle background', () {
    expect(
      BattleArenaWidget.backgroundAssetForWorld('world_2'),
      BattleArenaWidget.worldTwoBackgroundAsset,
    );
    expect(
      BattleArenaWidget.backgroundAssetForWorld('world_1'),
      BattleArenaWidget.meadowBackgroundAsset,
    );

    final bytes = File(BattleArenaWidget.worldTwoBackgroundAsset)
        .readAsBytesSync();
    final background = image.decodePng(bytes);

    expect(background, isNotNull);
    expect(background!.width, 2041);
    expect(background.height, 770);
  });

  test('World 3 uses its supplied Puzzle Peak battle background', () {
    expect(
      BattleArenaWidget.backgroundAssetForWorld('world_3'),
      BattleArenaWidget.worldThreeBackgroundAsset,
    );
    expect(
      BattleArenaWidget.backgroundAssetForWorld('world_1'),
      BattleArenaWidget.meadowBackgroundAsset,
    );

    final bytes = File(BattleArenaWidget.worldThreeBackgroundAsset)
        .readAsBytesSync();
    final background = image.decodePng(bytes);

    expect(background, isNotNull);
    expect(background!.width, 2042);
    expect(background.height, 770);
  });

  test('World 2 battle uses Frost Regent Veyr and all supplied states', () {
    final villain = MonsterModel.getForWorld('world_2');

    expect(villain.id, 'm_frost_regent_veyr');
    expect(villain.name, 'Frost Regent Veyr');
    expect(
      BattleArenaWidget.monsterAssetForState(
        worldId: 'world_2',
        isSubmitted: false,
        isCorrect: false,
        impactProgress: 0,
        hitCount: 0,
      ),
      BattleArenaWidget.worldTwoMonsterStandingAsset,
    );
    expect(
      BattleArenaWidget.monsterAssetForState(
        worldId: 'world_2',
        isSubmitted: true,
        isCorrect: false,
        impactProgress: 0,
        hitCount: 0,
      ),
      BattleArenaWidget.worldTwoMonsterAttackAsset,
    );
    expect(
      BattleArenaWidget.monsterAssetForState(
        worldId: 'world_2',
        isSubmitted: true,
        isCorrect: true,
        impactProgress: 0.5,
        hitCount: 1,
      ),
      BattleArenaWidget.worldTwoMonsterHurtAsset,
    );
    expect(
      BattleArenaWidget.monsterProjectileAssetForWorld('world_2'),
      BattleArenaWidget.worldTwoMonsterProjectileAsset,
    );
    expect(
      BattleArenaWidget.monsterProjectileAssetForWorld('world_1'),
      'assets/images/monster_attack_effect.png',
    );
  });

  test(
    'World 3 battle uses Crimson Arcanist Zarek and all supplied states',
    () {
      final villain = MonsterModel.getForWorld('world_3');

      expect(villain.id, 'm_crimson_arcanist_zarek');
      expect(villain.name, 'Crimson Arcanist Zarek');
      expect(
        BattleArenaWidget.monsterAssetForState(
          worldId: 'world_3',
          isSubmitted: false,
          isCorrect: false,
          impactProgress: 0,
          hitCount: 0,
        ),
        BattleArenaWidget.worldThreeMonsterStandingAsset,
      );
      expect(
        BattleArenaWidget.monsterAssetForState(
          worldId: 'world_3',
          isSubmitted: true,
          isCorrect: false,
          impactProgress: 0,
          hitCount: 0,
        ),
        BattleArenaWidget.worldThreeMonsterAttackAsset,
      );
      expect(
        BattleArenaWidget.monsterAssetForState(
          worldId: 'world_3',
          isSubmitted: true,
          isCorrect: true,
          impactProgress: 0.5,
          hitCount: 1,
        ),
        BattleArenaWidget.worldThreeMonsterHurtAsset,
      );
      expect(
        BattleArenaWidget.monsterProjectileAssetForWorld('world_3'),
        BattleArenaWidget.worldThreeMonsterProjectileAsset,
      );
    },
  );

  testWidgets('Illustrated villains render larger without changing World 1', (
    tester,
  ) async {
    Widget battle(String worldId) => MaterialApp(
      home: Scaffold(
        body: BattleArenaWidget(
          worldId: worldId,
          player: const PlayerModel(),
          monster: MonsterModel.getForWorld(worldId),
          isSubmitted: false,
          isCorrect: false,
        ),
      ),
    );

    await tester.pumpWidget(battle('world_2'));
    expect(tester.getSize(find.byType(BattleArenaWidget)).height, 190);
    final veyrImage = tester.widget<Image>(
      find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName ==
                BattleArenaWidget.worldTwoMonsterStandingAsset,
      ),
    );
    expect(veyrImage.height, 130);

    await tester.pumpWidget(battle('world_3'));
    expect(tester.getSize(find.byType(BattleArenaWidget)).height, 190);
    final zarekImage = tester.widget<Image>(
      find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName ==
                BattleArenaWidget.worldThreeMonsterStandingAsset,
      ),
    );
    expect(zarekImage.height, 130);

    await tester.pumpWidget(battle('world_1'));
    expect(tester.getSize(find.byType(BattleArenaWidget)).height, 155);
  });

  testWidgets('World 3 defaults to the blue illustrated Math Explorer', (
    tester,
  ) async {
    Widget battle({required bool isSubmitted, required bool isCorrect}) =>
        MaterialApp(
          home: Scaffold(
            body: BattleArenaWidget(
              worldId: 'world_3',
              player: const PlayerModel(),
              monster: MonsterModel.getForWorld('world_3'),
              isSubmitted: isSubmitted,
              isCorrect: isCorrect,
            ),
          ),
        );

    Future<void> expectExplorerAsset(String asset) async {
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Image &&
              widget.image is AssetImage &&
              (widget.image as AssetImage).assetName == asset,
        ),
        findsOneWidget,
      );
    }

    await tester.pumpWidget(battle(isSubmitted: false, isCorrect: false));
    await expectExplorerAsset(BattleArenaWidget.mathExplorerStandingAsset);

    await tester.pumpWidget(battle(isSubmitted: true, isCorrect: true));
    await expectExplorerAsset(BattleArenaWidget.mathExplorerAttackAsset);

    await tester.pumpWidget(battle(isSubmitted: true, isCorrect: false));
    await expectExplorerAsset(BattleArenaWidget.mathExplorerHurtAsset);
  });

  testWidgets('selected female wizard uses all three battle sprites', (
    tester,
  ) async {
    Widget battle({required bool isSubmitted, required bool isCorrect}) =>
        MaterialApp(
          home: Scaffold(
            body: BattleArenaWidget(
              worldId: 'world_3',
              player: const PlayerModel(avatarId: 'hero_girl'),
              monster: MonsterModel.getForWorld('world_3'),
              isSubmitted: isSubmitted,
              isCorrect: isCorrect,
            ),
          ),
        );

    void expectFemaleSprite(String asset) {
      expect(find.image(AssetImage(asset)), findsOneWidget, reason: asset);
    }

    await tester.pumpWidget(battle(isSubmitted: false, isCorrect: false));
    expectFemaleSprite(BattleArenaWidget.femaleWizardStandingAsset);

    await tester.pumpWidget(battle(isSubmitted: true, isCorrect: true));
    expectFemaleSprite(BattleArenaWidget.femaleWizardAttackAsset);

    await tester.pumpWidget(battle(isSubmitted: true, isCorrect: false));
    expectFemaleSprite(BattleArenaWidget.femaleWizardHurtAsset);
  });

  test('female wizard battle sprites are transparent PNG assets', () {
    final expectedSizes = {
      BattleArenaWidget.femaleWizardStandingAsset: [1024, 1536],
      BattleArenaWidget.femaleWizardAttackAsset: [1397, 1126],
      BattleArenaWidget.femaleWizardHurtAsset: [1402, 1122],
    };

    for (final entry in expectedSizes.entries) {
      final sprite = image.decodePng(File(entry.key).readAsBytesSync());

      expect(sprite, isNotNull, reason: entry.key);
      expect(sprite!.width, entry.value[0], reason: entry.key);
      expect(sprite.height, entry.value[1], reason: entry.key);
      expect(sprite.numChannels, 4, reason: entry.key);
      expect(sprite.getPixel(0, 0).a, 0, reason: entry.key);
      expect(
        sprite.getPixel(sprite.width - 1, sprite.height - 1).a,
        0,
        reason: entry.key,
      );
    }
  });

  test('World 2 villain sprites are transparent PNG assets', () {
    final expectedSizes = {
      BattleArenaWidget.worldTwoMonsterStandingAsset: [1024, 1536],
      BattleArenaWidget.worldTwoMonsterAttackAsset: [1536, 1024],
      BattleArenaWidget.worldTwoMonsterHurtAsset: [1199, 1312],
      BattleArenaWidget.worldTwoMonsterProjectileAsset: [1774, 887],
    };

    for (final entry in expectedSizes.entries) {
      final sprite = image.decodePng(File(entry.key).readAsBytesSync());

      expect(sprite, isNotNull, reason: entry.key);
      expect(sprite!.width, entry.value[0], reason: entry.key);
      expect(sprite.height, entry.value[1], reason: entry.key);
      expect(sprite.numChannels, 4, reason: entry.key);
      expect(sprite.getPixel(0, 0).a, 0, reason: entry.key);
      expect(
        sprite.getPixel(sprite.width - 1, sprite.height - 1).a,
        0,
        reason: entry.key,
      );
    }
  });

  test('World 3 Zarek sprites are transparent PNG assets', () {
    final expectedSizes = {
      BattleArenaWidget.worldThreeMonsterStandingAsset: [1151, 1367],
      BattleArenaWidget.worldThreeMonsterAttackAsset: [1030, 877],
      BattleArenaWidget.worldThreeMonsterHurtAsset: [704, 822],
      BattleArenaWidget.worldThreeMonsterProjectileAsset: [2030, 775],
    };

    for (final entry in expectedSizes.entries) {
      final sprite = image.decodePng(File(entry.key).readAsBytesSync());

      expect(sprite, isNotNull, reason: entry.key);
      expect(sprite!.width, entry.value[0], reason: entry.key);
      expect(sprite.height, entry.value[1], reason: entry.key);
      expect(sprite.numChannels, 4, reason: entry.key);
      expect(sprite.getPixel(0, 0).a, 0, reason: entry.key);
      expect(
        sprite.getPixel(sprite.width - 1, sprite.height - 1).a,
        0,
        reason: entry.key,
      );
    }
  });

  test('World 2 standing sprite faces the mirrored direction', () {
    final sprite = image.decodePng(
      File(BattleArenaWidget.worldTwoMonsterStandingAsset).readAsBytesSync(),
    )!;

    // The staff tip is now on the right, while the matching left area is clear.
    expect(sprite.getPixel(790, 30).a, greaterThan(200));
    expect(sprite.getPixel(240, 30).a, 0);
  });

  test('cheat-code file covers every playable level exactly once', () {
    final worlds = WorldRepository.getAllWorlds();
    final levels = worlds.expand((world) => world.levels).toList();

    expect(LevelCheatCodes.all, hasLength(levels.length));
    expect(
      LevelCheatCodes.all.map((entry) => entry.code).toSet(),
      hasLength(LevelCheatCodes.all.length),
    );
    expect(
      LevelCheatCodes.all.map((entry) => entry.levelId).toSet(),
      levels.map((level) => level.id).toSet(),
    );
    expect(LevelCheatCodes.resolveLevel('mq lvl 06', worlds)?.id, 'w2_l1');
    expect(LevelCheatCodes.resolveLevel('invalid', worlds), isNull);
  });

  test('test-mode level completion never mutates player progress', () async {
    SharedPreferences.setMockInitialValues({});
    final provider = GameProvider();
    while (provider.isLoading) {
      await Future<void>.delayed(Duration.zero);
    }

    final preferences = await SharedPreferences.getInstance();
    final playerBefore = provider.player;
    final serializedBefore = playerBefore.serialize();
    final storedBefore = preferences.getString('player_data');
    final level = LevelCheatCodes.resolveLevel('MQ-LVL-10', provider.worlds)!;

    provider.startTestLevel(level);
    expect(provider.isTestMode, isTrue);

    for (var mistake = 0; mistake < 3; mistake++) {
      final wrongAnswer =
          (provider.currentQuestion!.correctAnswerIndex + 1) %
          provider.currentQuestion!.options.length;
      provider.selectAnswer(wrongAnswer);
      provider.submitAnswer();
      if (mistake < 2) provider.nextQuestion();
    }
    expect(provider.levelHeartsLeft, 0);
    expect(provider.reviveLevelWithGems(), isTrue);
    expect(provider.levelHeartsLeft, 3);
    expect(provider.player.gems, playerBefore.gems);

    provider.restartActiveLevel();
    expect(provider.isTestMode, isTrue);
    expect(provider.useHint(), isTrue);
    expect(provider.player.gems, playerBefore.gems);

    while (!provider.isLevelCompleted) {
      provider.selectAnswer(provider.currentQuestion!.correctAnswerIndex);
      provider.submitAnswer();
      provider.nextQuestion();
    }

    expect(identical(provider.player, playerBefore), isTrue);
    expect(provider.player.serialize(), serializedBefore);
    expect(preferences.getString('player_data'), storedBefore);
    expect(provider.pendingConstructionLevelId, isNull);

    provider.endTestSession();
    expect(provider.isTestMode, isFalse);
    expect(provider.activeLevel, isNull);
    provider.dispose();
  });

  testWidgets('cheat console launches the requested locked level', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final provider = GameProvider();
    while (provider.isLoading) {
      await tester.pump();
    }

    await tester.pumpWidget(
      ChangeNotifierProvider<GameProvider>.value(
        value: provider,
        child: const MaterialApp(home: OnboardingScreen()),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('cheat-code-access-button')));
    await tester.pump();
    await tester.enterText(
      find.byKey(const ValueKey('cheat-code-input')),
      'MQ-LVL-06',
    );
    await tester.tap(find.byKey(const ValueKey('activate-cheat-code')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(GameplayScreen), findsOneWidget);
    expect(provider.isTestMode, isTrue);
    expect(provider.activeLevel?.id, 'w2_l1');

    await tester.pumpWidget(const SizedBox.shrink());
    provider.endTestSession();
    provider.dispose();
  });

  test('player current world stops at the highest illustrated world', () {
    const legacyPlayer = PlayerModel(
      unlockedWorldIds: {'world_1', 'world_2', 'world_3', 'world_4'},
    );

    expect(legacyPlayer.currentWorldId, 'world_3');
  });

  test(
    'game initialization keeps world 3 and removes later retired progress',
    () async {
      final legacyPlayer = const PlayerModel(
        completedLevelIds: {'w1_l5', 'w3_l1', 'w4_l1'},
        unlockedWorldIds: {'world_1', 'world_2', 'world_3', 'world_4'},
        levelStars: {
          'w1_l1': 3,
          'w1_l2': 3,
          'w1_l3': 3,
          'w1_l4': 3,
          'w1_l5': 3,
          'w2_l1': 3,
          'w2_l2': 3,
          'w2_l3': 3,
          'w2_l4': 1,
          'w3_l1': 3,
          'w4_l1': 3,
        },
      );
      SharedPreferences.setMockInitialValues({
        'player_data': legacyPlayer.serialize(),
      });

      final provider = GameProvider();
      while (provider.isLoading) {
        await Future<void>.delayed(Duration.zero);
      }

      expect(provider.player.unlockedWorldIds, {
        'world_1',
        'world_2',
        'world_3',
      });
      expect(provider.player.completedLevelIds, {'w1_l5', 'w3_l1'});
      expect(provider.player.levelStars, isNot(contains('w4_l1')));
      provider.dispose();
    },
  );

  testWidgets('map uses world 3 artwork and clouds across both seams', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final provider = GameProvider();
    while (provider.isLoading) {
      await tester.pump();
    }

    await tester.pumpWidget(
      ChangeNotifierProvider<GameProvider>.value(
        value: provider,
        child: const MaterialApp(home: Scaffold(body: AdventureMapScreen())),
      ),
    );

    Finder assetImages(String assetName) => find.byWidgetPredicate(
      (widget) =>
          widget is Image &&
          widget.image is AssetImage &&
          (widget.image as AssetImage).assetName == assetName,
    );

    expect(assetImages('assets/images/world_3_map_bg.png'), findsOneWidget);
    expect(assetImages('assets/images/world_2_map_bg.png'), findsOneWidget);
    expect(assetImages('assets/images/world_2_map_bg.jpg'), findsNothing);
    expect(
      assetImages('assets/images/map_cloud_transition.png'),
      findsNWidgets(6),
    );
    expect(find.byType(AmbientButterfly), findsNWidgets(3));
    expect(
      find.byKey(const ValueKey('ambient-butterfly-meadow-orange')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('ambient-butterfly-waterside-yellow')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('ambient-butterfly-grove-blue')),
      findsOneWidget,
    );
    expect(find.byType(AmbientLeafField), findsOneWidget);
    for (var index = 0; index < 3; index++) {
      expect(find.byKey(ValueKey('ambient-leaf-$index')), findsOneWidget);
    }
    expect(find.byType(WorldThreeLuminaField), findsOneWidget);
    expect(find.byType(WorldTwoIcyWindOverlay), findsOneWidget);
    expect(find.byType(WorldTwoSnowOverlay), findsOneWidget);
    for (var index = 0; index < 2; index++) {
      expect(find.byKey(ValueKey('world-three-lumina-$index')), findsOneWidget);
    }

    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    provider.dispose();
  });

  test('World 2 snowy map keeps its source aspect ratio', () {
    final bytes = File('assets/images/world_2_map_bg.png').readAsBytesSync();
    final map = image.decodePng(bytes);

    expect(map, isNotNull);
    expect(map!.width, 941);
    expect(map.height, 1672);
  });

  test('World 2 icy wind is a transparent PNG', () {
    final bytes = File(WorldTwoIcyWindOverlay.assetPath).readAsBytesSync();
    final wind = image.decodePng(bytes);

    expect(wind, isNotNull);
    expect(wind!.width, WorldTwoIcyWindOverlay.sourceSize.width);
    expect(wind.height, WorldTwoIcyWindOverlay.sourceSize.height);
    expect(wind.numChannels, 4);
    expect(wind.getPixel(0, 0).a, 0);
    expect(wind.getPixel(wind.width - 1, wind.height - 1).a, 0);
  });

  test('World 2 icy wind loops invisibly at the screen edges', () {
    expect(WorldTwoIcyWindOverlay.loopProgress(Duration.zero, 22), 0);
    expect(
      WorldTwoIcyWindOverlay.loopProgress(const Duration(seconds: 11), 22),
      0.5,
    );
    expect(
      WorldTwoIcyWindOverlay.loopProgress(const Duration(seconds: 22), 22),
      0,
    );
    expect(WorldTwoIcyWindOverlay.windOpacity(0), closeTo(0, 0.0001));
    expect(WorldTwoIcyWindOverlay.windOpacity(0.5), greaterThan(0.10));
    expect(WorldTwoIcyWindOverlay.windOpacity(1), closeTo(0, 0.0001));

    final start = WorldTwoIcyWindOverlay.windPosition(0, 390, 700, 265);
    final end = WorldTwoIcyWindOverlay.windPosition(1, 390, 700, 265);
    expect(start.dx, -265);
    expect(end.dx, 390);
  });

  test('World 2 snow texture preserves transparent PNG edges', () {
    final bytes = File(WorldTwoSnowOverlay.assetPath).readAsBytesSync();
    final snow = image.decodePng(bytes);

    expect(snow, isNotNull);
    expect(snow!.width, WorldTwoSnowOverlay.sourceSize.width);
    expect(snow.height, WorldTwoSnowOverlay.sourceSize.height);
    expect(snow.numChannels, 4);
    expect(snow.getPixel(0, 0).a, lessThanOrEqualTo(2));
    expect(
      snow.getPixel(snow.width - 1, snow.height - 1).a,
      lessThanOrEqualTo(2),
    );
  });

  test('World 2 snow depth layers loop with distinct motion', () {
    expect(WorldTwoSnowOverlay.depthLayers, hasLength(2));
    expect(
      WorldTwoSnowOverlay.depthLayers.map((layer) => layer.scale).toSet(),
      hasLength(2),
    );
    expect(
      WorldTwoSnowOverlay.depthLayers
          .map((layer) => layer.periodSeconds)
          .toSet(),
      hasLength(2),
    );
    expect(WorldTwoSnowOverlay.loopProgress(Duration.zero, 20), 0);
    expect(
      WorldTwoSnowOverlay.loopProgress(const Duration(seconds: 20), 20),
      0,
    );
    expect(WorldTwoSnowOverlay.verticalOffset(0, 600), 0);
    expect(WorldTwoSnowOverlay.verticalOffset(1, 600), 600);
    expect(
      WorldTwoSnowOverlay.horizontalDrift(0, 390, 0.02),
      closeTo(0, 0.0001),
    );
    expect(
      WorldTwoSnowOverlay.horizontalDrift(1, 390, 0.02),
      closeTo(0, 0.0001),
    );
  });

  test(
    'level house construction persists each log and completes at stage 4',
    () async {
      final player = const PlayerModel(
        woodLogs: 5,
        completedLevelIds: {'w1_l1'},
      );
      SharedPreferences.setMockInitialValues({
        'player_data': player.serialize(),
      });

      final provider = GameProvider();
      while (provider.isLoading) {
        await Future<void>.delayed(Duration.zero);
      }
      final level = provider.worlds.first.levels.first;

      expect(provider.levelHouseStage(level), 0);
      for (var stage = 1; stage <= GameProvider.levelHouseFinalStage; stage++) {
        expect(provider.advanceLevelHouseConstruction(level), isTrue);
        expect(provider.levelHouseStage(level), stage);
      }

      expect(provider.isLevelHouseComplete(level), isTrue);
      expect(provider.player.woodLogs, 1);
      expect(provider.advanceLevelHouseConstruction(level), isFalse);
      expect(provider.player.woodLogs, 1);
      provider.dispose();
    },
  );

  test('World 2 Level 6 cabin construction saves independently', () async {
    final player = const PlayerModel(
      woodLogs: 5,
      completedLevelIds: {'w1_l5', 'w2_l1'},
      buildingStages: {'hut_w1_l1': 4},
    );
    SharedPreferences.setMockInitialValues({'player_data': player.serialize()});

    final provider = GameProvider();
    while (provider.isLoading) {
      await Future<void>.delayed(Duration.zero);
    }
    final world2 = provider.worlds.firstWhere((world) => world.id == 'world_2');
    final level6 = world2.levels.first;

    expect(provider.supportsLevelBuilding(level6), isTrue);
    expect(provider.supportsLevelBuilding(world2.levels[1]), isTrue);
    expect(provider.levelHouseStage(level6), 0);
    for (var stage = 1; stage <= GameProvider.levelHouseFinalStage; stage++) {
      expect(provider.advanceLevelHouseConstruction(level6), isTrue);
      expect(provider.levelHouseStage(level6), stage);
    }
    expect(provider.isLevelHouseComplete(level6), isTrue);
    expect(provider.player.buildingStages['hut_w1_l1'], 4);
    expect(provider.player.woodLogs, 1);
    expect(provider.advanceLevelHouseConstruction(level6), isFalse);

    await provider.saveProgress();
    final preferences = await SharedPreferences.getInstance();
    final savedPlayer = PlayerModel.deserialize(
      preferences.getString('player_data')!,
    );
    expect(savedPlayer.buildingStages['hut_w2_l1'], 4);
    provider.dispose();
  });

  test('World 2 Level 7 watermill construction saves independently', () async {
    final player = const PlayerModel(
      woodLogs: 4,
      completedLevelIds: {'w1_l5', 'w2_l1', 'w2_l2'},
      buildingStages: {'hut_w2_l1': 4},
    );
    SharedPreferences.setMockInitialValues({'player_data': player.serialize()});

    final provider = GameProvider();
    while (provider.isLoading) {
      await Future<void>.delayed(Duration.zero);
    }
    final world2 = provider.worlds.firstWhere((world) => world.id == 'world_2');
    final level7 = world2.levels[1];

    expect(provider.supportsLevelBuilding(level7), isTrue);
    expect(provider.levelHouseStage(level7), 0);
    for (var stage = 1; stage <= GameProvider.levelHouseFinalStage; stage++) {
      expect(provider.advanceLevelHouseConstruction(level7), isTrue);
      expect(provider.levelHouseStage(level7), stage);
    }
    expect(provider.isLevelHouseComplete(level7), isTrue);
    expect(provider.player.buildingStages['hut_w2_l1'], 4);
    expect(provider.player.woodLogs, 0);

    await provider.saveProgress();
    final preferences = await SharedPreferences.getInstance();
    final savedPlayer = PlayerModel.deserialize(
      preferences.getString('player_data')!,
    );
    expect(savedPlayer.buildingStages['hut_w2_l2'], 4);
    provider.dispose();
  });

  test(
    'World 2 Level 8 observatory construction saves independently',
    () async {
      final player = const PlayerModel(
        woodLogs: 4,
        completedLevelIds: {'w1_l5', 'w2_l1', 'w2_l2', 'w2_l3'},
        buildingStages: {'hut_w2_l1': 4, 'hut_w2_l2': 4},
      );
      SharedPreferences.setMockInitialValues({
        'player_data': player.serialize(),
      });

      final provider = GameProvider();
      while (provider.isLoading) {
        await Future<void>.delayed(Duration.zero);
      }
      final world2 = provider.worlds.firstWhere(
        (world) => world.id == 'world_2',
      );
      final level8 = world2.levels[2];

      expect(provider.supportsLevelBuilding(level8), isTrue);
      expect(provider.levelHouseStage(level8), 0);
      for (var stage = 1; stage <= GameProvider.levelHouseFinalStage; stage++) {
        expect(provider.advanceLevelHouseConstruction(level8), isTrue);
        expect(provider.levelHouseStage(level8), stage);
      }
      expect(provider.isLevelHouseComplete(level8), isTrue);
      expect(provider.player.buildingStages['hut_w2_l1'], 4);
      expect(provider.player.buildingStages['hut_w2_l2'], 4);
      expect(provider.player.woodLogs, 0);

      await provider.saveProgress();
      final preferences = await SharedPreferences.getInstance();
      final savedPlayer = PlayerModel.deserialize(
        preferences.getString('player_data')!,
      );
      expect(savedPlayer.buildingStages['hut_w2_l3'], 4);
      provider.dispose();
    },
  );

  test('World 2 Level 9 guildhall construction saves independently', () async {
    final player = const PlayerModel(
      woodLogs: 4,
      completedLevelIds: {'w1_l5', 'w2_l1', 'w2_l2', 'w2_l3', 'w2_l4'},
      buildingStages: {'hut_w2_l1': 4, 'hut_w2_l2': 4, 'hut_w2_l3': 4},
    );
    SharedPreferences.setMockInitialValues({'player_data': player.serialize()});

    final provider = GameProvider();
    while (provider.isLoading) {
      await Future<void>.delayed(Duration.zero);
    }
    final world2 = provider.worlds.firstWhere((world) => world.id == 'world_2');
    final level9 = world2.levels[3];

    expect(provider.supportsLevelBuilding(level9), isTrue);
    expect(provider.levelHouseStage(level9), 0);
    for (var stage = 1; stage <= GameProvider.levelHouseFinalStage; stage++) {
      expect(provider.advanceLevelHouseConstruction(level9), isTrue);
      expect(provider.levelHouseStage(level9), stage);
    }
    expect(provider.isLevelHouseComplete(level9), isTrue);
    expect(provider.player.buildingStages['hut_w2_l3'], 4);
    expect(provider.player.woodLogs, 0);

    await provider.saveProgress();
    final preferences = await SharedPreferences.getInstance();
    final savedPlayer = PlayerModel.deserialize(
      preferences.getString('player_data')!,
    );
    expect(savedPlayer.buildingStages['hut_w2_l4'], 4);
    provider.dispose();
  });

  test(
    'World 2 Level 10 ice castle construction saves independently',
    () async {
      final player = const PlayerModel(
        woodLogs: 4,
        completedLevelIds: {
          'w1_l5',
          'w2_l1',
          'w2_l2',
          'w2_l3',
          'w2_l4',
          'w2_l5',
        },
        buildingStages: {'hut_w2_l4': 4},
      );
      SharedPreferences.setMockInitialValues({
        'player_data': player.serialize(),
      });

      final provider = GameProvider();
      while (provider.isLoading) {
        await Future<void>.delayed(Duration.zero);
      }
      final world2 = provider.worlds.firstWhere(
        (world) => world.id == 'world_2',
      );
      final level10 = world2.levels[4];

      expect(provider.supportsLevelBuilding(level10), isTrue);
      expect(provider.levelHouseStage(level10), 0);
      for (var stage = 1; stage <= GameProvider.levelHouseFinalStage; stage++) {
        expect(provider.advanceLevelHouseConstruction(level10), isTrue);
        expect(provider.levelHouseStage(level10), stage);
      }
      expect(provider.isLevelHouseComplete(level10), isTrue);
      expect(provider.player.buildingStages['hut_w2_l4'], 4);
      expect(provider.player.woodLogs, 0);

      await provider.saveProgress();
      final preferences = await SharedPreferences.getInstance();
      final savedPlayer = PlayerModel.deserialize(
        preferences.getString('player_data')!,
      );
      expect(savedPlayer.buildingStages['hut_w2_l5'], 4);
      provider.dispose();
    },
  );

  test(
    'canonical completed house is not hidden by a zero legacy stage',
    () async {
      final player = const PlayerModel(
        completedLevelIds: {'w1_l1'},
        buildingStages: {'hut_level_1': 0, 'hut_w1_l1': 4},
      );
      SharedPreferences.setMockInitialValues({
        'player_data': player.serialize(),
      });

      final provider = GameProvider();
      while (provider.isLoading) {
        await Future<void>.delayed(Duration.zero);
      }
      final level = provider.worlds.first.levels.first;

      expect(
        provider.levelHouseStage(level),
        GameProvider.levelHouseFinalStage,
      );
      expect(provider.isLevelHouseComplete(level), isTrue);
      provider.dispose();
    },
  );

  test('construction progress maps to exactly one sequential visual', () {
    expect(
      List.generate(
        5,
        (progress) => FoundationBuilderScreen.imageForProgress(
          progress: progress,
          levelNumber: 1,
        ),
      ),
      [
        'assets/images/world1_level1_stage0.png',
        'assets/images/world1_level1_stage1.png',
        'assets/images/world1_level1_stage2.png',
        'assets/images/world1_level1_stage3.png',
        'assets/images/world1_level1_complete.png',
      ],
    );
    expect(
      FoundationBuilderScreen.imageForProgress(progress: 4, levelNumber: 5),
      'assets/images/world1_level5_complete.png',
    );
    expect(
      List.generate(
        5,
        (progress) => FoundationBuilderScreen.imageForProgress(
          progress: progress,
          levelNumber: 2,
        ),
      ),
      [
        'assets/images/world1_level2_stage0.png',
        'assets/images/world1_level2_stage1.png',
        'assets/images/world1_level2_stage2.png',
        'assets/images/world1_level2_stage3.png',
        'assets/images/world1_level2_complete.png',
      ],
    );
    expect(
      FoundationBuilderScreen.imageForProgress(progress: 99, levelNumber: 1),
      'assets/images/world1_level1_complete.png',
    );
  });

  test('construction assets stay within the phone-loading budget', () {
    final assets = WorldRepository.getAllWorlds()
        .expand((world) => world.levels)
        .expand(FoundationBuilderScreen.assetsForLevel)
        .toList(growable: false);

    expect(assets, hasLength(75));
    expect(assets.toSet(), hasLength(75));
    final files = assets.map(File.new).toList(growable: false);
    expect(files.every((file) => file.existsSync()), isTrue);
    expect(
      files.every((file) => file.lengthSync() < 1024 * 1024),
      isTrue,
      reason: 'Each stage should remain below 1 MB for quick transitions.',
    );
    expect(
      files.fold<int>(0, (total, file) => total + file.lengthSync()),
      lessThan(60 * 1024 * 1024),
      reason: 'The full construction set should remain below 60 MB.',
    );
  });

  test('World 2 Level 6 cabin uses its own five construction visuals', () {
    expect(
      List.generate(
        5,
        (progress) => FoundationBuilderScreen.imageForProgress(
          progress: progress,
          levelNumber: 6,
          worldId: 'world_2',
        ),
      ),
      [
        'assets/images/world2_level6_stage0.png',
        'assets/images/world2_level6_stage1.png',
        'assets/images/world2_level6_stage2.png',
        'assets/images/world2_level6_stage3.png',
        'assets/images/world2_level6_complete.png',
      ],
    );
  });

  test('World 2 Level 7 watermill uses its own five construction visuals', () {
    expect(
      List.generate(
        5,
        (progress) => FoundationBuilderScreen.imageForProgress(
          progress: progress,
          levelNumber: 7,
          worldId: 'world_2',
        ),
      ),
      [
        'assets/images/world2_level7_stage0.png',
        'assets/images/world2_level7_stage1.png',
        'assets/images/world2_level7_stage2.png',
        'assets/images/world2_level7_stage3.png',
        'assets/images/world2_level7_complete.png',
      ],
    );
  });

  test(
    'World 2 Level 8 observatory uses its own five construction visuals',
    () {
      expect(
        List.generate(
          5,
          (progress) => FoundationBuilderScreen.imageForProgress(
            progress: progress,
            levelNumber: 8,
            worldId: 'world_2',
          ),
        ),
        [
          'assets/images/world2_level8_stage0.png',
          'assets/images/world2_level8_stage1.png',
          'assets/images/world2_level8_stage2.png',
          'assets/images/world2_level8_stage3.png',
          'assets/images/world2_level8_complete.png',
        ],
      );
    },
  );

  test('World 2 Level 9 guildhall uses its own five construction visuals', () {
    expect(
      List.generate(
        5,
        (progress) => FoundationBuilderScreen.imageForProgress(
          progress: progress,
          levelNumber: 9,
          worldId: 'world_2',
        ),
      ),
      [
        'assets/images/world2_level9_stage0.png',
        'assets/images/world2_level9_stage1.png',
        'assets/images/world2_level9_stage2.png',
        'assets/images/world2_level9_stage3.png',
        'assets/images/world2_level9_complete.png',
      ],
    );
  });

  test('World 2 Level 10 castle uses its own five construction visuals', () {
    expect(
      List.generate(
        5,
        (progress) => FoundationBuilderScreen.imageForProgress(
          progress: progress,
          levelNumber: 10,
          worldId: 'world_2',
        ),
      ),
      [
        'assets/images/world2_level10_stage0.png',
        'assets/images/world2_level10_stage1.png',
        'assets/images/world2_level10_stage2.png',
        'assets/images/world2_level10_stage3.png',
        'assets/images/world2_level10_complete.png',
      ],
    );
  });

  test('level 3 starts on its own plot and ends in its own building', () {
    expect(
      List.generate(
        5,
        (progress) => FoundationBuilderScreen.imageForProgress(
          progress: progress,
          levelNumber: 3,
        ),
      ),
      [
        'assets/images/world1_level3_stage0.png',
        'assets/images/world1_level3_stage1.png',
        'assets/images/world1_level3_stage2.png',
        'assets/images/world1_level3_stage3.png',
        'assets/images/world1_level3_complete.png',
      ],
    );
    expect(
      FoundationBuilderScreen.imageForProgress(progress: 99, levelNumber: 3),
      'assets/images/world1_level3_complete.png',
    );
  });

  test('level 4 starts on its own plot and ends in its own building', () {
    expect(
      List.generate(
        5,
        (progress) => FoundationBuilderScreen.imageForProgress(
          progress: progress,
          levelNumber: 4,
        ),
      ),
      [
        'assets/images/world1_level4_stage0.png',
        'assets/images/world1_level4_stage1.png',
        'assets/images/world1_level4_stage2.png',
        'assets/images/world1_level4_stage3.png',
        'assets/images/world1_level4_complete.png',
      ],
    );
    expect(
      FoundationBuilderScreen.imageForProgress(progress: 99, levelNumber: 4),
      'assets/images/world1_level4_complete.png',
    );
  });

  test('level 5 starts on its own plot and ends in its own building', () {
    expect(
      List.generate(
        5,
        (progress) => FoundationBuilderScreen.imageForProgress(
          progress: progress,
          levelNumber: 5,
        ),
      ),
      [
        'assets/images/world1_level5_stage0.png',
        'assets/images/world1_level5_stage1.png',
        'assets/images/world1_level5_stage2.png',
        'assets/images/world1_level5_stage3.png',
        'assets/images/world1_level5_complete.png',
      ],
    );
    expect(
      FoundationBuilderScreen.imageForProgress(progress: 99, levelNumber: 5),
      'assets/images/world1_level5_complete.png',
    );
  });

  test('new construction sprites have transparent backgrounds', () {
    for (final level in [1, 2, 3, 4, 5]) {
      final completedBuilding = image.decodePng(
        File('assets/images/world1_level${level}_complete.png')
            .readAsBytesSync(),
      );
      expect(completedBuilding, isNotNull);
      expect(completedBuilding!.getPixel(0, 0).a, 0);
    }

    for (final prefix in [
      'world1_level1_stage',
      'world1_level2_stage',
      'world1_level3_stage',
      'world1_level4_stage',
      'world1_level5_stage',
      'construction_stage',
      'level3_construction',
      'level4_construction',
      'level5_construction',
    ]) {
      for (
        var stage = prefix.startsWith('world1_level') ? 0 : 1;
        stage <= 3;
        stage++
      ) {
        final assetName = prefix.startsWith('world1_level')
            ? 'assets/images/$prefix$stage.png'
            : 'assets/images/${prefix}_$stage.png';
        final bytes = File(assetName).readAsBytesSync();
        final sprite = image.decodePng(bytes);

        expect(sprite, isNotNull);
        expect(sprite!.numChannels, 4);
        expect(sprite.getPixel(0, 0).a, 0);
      }
    }

    for (final assetName in [
      for (final level in [6, 7, 8, 9, 10]) ...[
        for (var stage = 0; stage < 4; stage++)
          'assets/images/world2_level${level}_stage$stage.png',
        'assets/images/world2_level${level}_complete.png',
      ],
    ]) {
      final sprite = image.decodePng(File(assetName).readAsBytesSync());
      expect(sprite, isNotNull);
      expect(sprite!.getPixel(0, 0).a, 0);
    }
  });

  test('orange butterfly frames flap open, close, and open smoothly', () {
    expect(AmbientButterfly.framesPerSecond, inInclusiveRange(8, 12));
    expect(
      List.generate(
        14,
        (tick) => AmbientButterfly.frameIndexForProgress(tick / 60),
      ),
      [0, 1, 2, 3, 4, 5, 6, 7, 6, 5, 4, 3, 2, 1],
    );
  });

  test('butterfly flight remains in the same normalized map area', () {
    for (var step = 0; step <= 20; step++) {
      final small = AmbientButterfly.positionForProgress(step / 20, 390, 586);
      final large = AmbientButterfly.positionForProgress(step / 20, 780, 1172);
      final waterside = AmbientButterfly.positionForProgress(
        step / 20,
        390,
        586,
        area: ButterflyFlightArea.upperLeftWaterside,
        routeVariant: 1,
      );
      final grove = AmbientButterfly.positionForProgress(
        step / 20,
        390,
        586,
        area: ButterflyFlightArea.lowerLeftGrove,
        routeVariant: 2,
      );

      expect(small.dx / 390, inInclusiveRange(0.72, 0.81));
      expect(small.dy / 586, inInclusiveRange(0.84, 0.89));
      expect(waterside.dx / 390, inInclusiveRange(0.09, 0.17));
      expect(waterside.dy / 586, inInclusiveRange(0.34, 0.39));
      expect(grove.dx / 390, inInclusiveRange(0.07, 0.16));
      expect(grove.dy / 586, inInclusiveRange(0.61, 0.65));
      expect(large.dx, closeTo(small.dx * 2, 0.001));
      expect(large.dy, closeTo(small.dy * 2, 0.001));
    }
  });

  test('butterfly paths vary without jumping at their endpoints', () {
    final routeStarts = List.generate(
      3,
      (variant) => AmbientButterfly.positionForProgress(
        0,
        390,
        586,
        routeVariant: variant,
      ),
    );
    final routeMiddles = List.generate(
      3,
      (variant) => AmbientButterfly.positionForProgress(
        0.25,
        390,
        586,
        routeVariant: variant,
      ),
    );

    expect(routeStarts.toSet(), hasLength(1));
    expect(routeMiddles.toSet(), hasLength(3));
  });

  test('all butterfly rows are isolated transparent assets', () {
    final frameRows = [
      AmbientButterfly.orangeFrameAssets,
      AmbientButterfly.yellowFrameAssets,
      AmbientButterfly.blueFrameAssets,
    ];
    for (final row in frameRows) {
      expect(row, hasLength(8));
    }
    for (final assetPath in frameRows.expand((row) => row)) {
      final sprite = image.decodePng(File(assetPath).readAsBytesSync());

      expect(sprite, isNotNull);
      expect(sprite!.width, 216);
      expect(sprite.height, 216);
      expect(sprite.numChannels, 4);
      expect(sprite.getPixel(0, 0).a, 0);
      expect(sprite.getPixel(215, 215).a, 0);
    }
  });

  test('leaf sprites are isolated transparent individual assets', () {
    final leafAssets = AmbientLeafField.leafSpecs
        .expand((spec) => spec.assets)
        .toSet();

    expect(leafAssets, hasLength(4));
    for (final assetPath in leafAssets) {
      final sprite = image.decodePng(File(assetPath).readAsBytesSync());

      expect(sprite, isNotNull);
      expect(sprite!.width, 192);
      expect(sprite.height, 192);
      expect(sprite.numChannels, 4);
      expect(sprite.getPixel(0, 0).a, 0);
      expect(sprite.getPixel(191, 191).a, 0);
    }
  });

  test('leaf spawning stays staggered and sparse', () {
    final initialProgress = AmbientLeafField.leafSpecs
        .map(
          (spec) => AmbientLeafField.lifecycleAt(
            Duration.zero,
            spec.phaseOffset,
          ).progress,
        )
        .toSet();
    expect(initialProgress, hasLength(3));

    for (var second = 0; second < AmbientLeafField.cycleSeconds; second++) {
      final visibleLeaves = AmbientLeafField.leafSpecs.where((spec) {
        final lifecycle = AmbientLeafField.lifecycleAt(
          Duration(seconds: second),
          spec.phaseOffset,
        );
        return AmbientLeafField.opacityForProgress(lifecycle.progress) > 0;
      }).length;
      expect(visibleLeaves, inInclusiveRange(2, 3));
    }

    final coloredLeaf = AmbientLeafField.leafSpecs.last;
    expect(
      AmbientLeafField.assetForCycle(coloredLeaf, 0),
      'assets/images/leaf_yellow_1.png',
    );
    expect(
      AmbientLeafField.assetForCycle(coloredLeaf, 1),
      'assets/images/leaf_orange_1.png',
    );
  });

  test('leaf paths scale with the map and curve along forest edges', () {
    for (final spec in AmbientLeafField.leafSpecs) {
      for (var step = 0; step <= 10; step++) {
        final progress = step / 10;
        final small = AmbientLeafField.positionForProgress(
          spec,
          progress,
          390,
          586,
          1,
        );
        final large = AmbientLeafField.positionForProgress(
          spec,
          progress,
          780,
          1172,
          1,
        );

        expect(large.dx, closeTo(small.dx * 2, 0.001));
        expect(large.dy, closeTo(small.dy * 2, 0.001));
        expect(small.dx / 390, anyOf(lessThan(0.13), greaterThan(0.87)));
      }

      expect(
        AmbientLeafField.rotationForProgress(spec, 0.65),
        isNot(AmbientLeafField.rotationForProgress(spec, 0.25)),
      );
    }
  });

  test('lumina-moth frames are transparent and preserve warm color', () {
    expect(WorldThreeLuminaField.frameAssets, hasLength(9));
    for (final assetPath in WorldThreeLuminaField.frameAssets) {
      final sprite = image.decodePng(File(assetPath).readAsBytesSync());

      expect(sprite, isNotNull);
      expect(sprite!.width, 192);
      expect(sprite.height, 192);
      expect(sprite.numChannels, 4);
      expect(sprite.getPixel(0, 0).a, 0);
      expect(sprite.getPixel(191, 191).a, 0);

      var hasWarmOpaquePixel = false;
      for (var y = 0; y < sprite.height && !hasWarmOpaquePixel; y++) {
        for (var x = 0; x < sprite.width; x++) {
          final pixel = sprite.getPixel(x, y);
          if (pixel.a > 200 && pixel.r > pixel.b + 20) {
            hasWarmOpaquePixel = true;
            break;
          }
        }
      }
      expect(hasWarmOpaquePixel, isTrue);
    }
  });

  test('lumina-moth wings flap at 10 FPS and glow without flashing', () {
    expect(WorldThreeLuminaField.framesPerSecond, inInclusiveRange(8, 12));
    expect(
      List.generate(
        16,
        (tick) => WorldThreeLuminaField.frameIndexAt(
          Duration(milliseconds: tick * 100),
          0,
        ),
      ),
      [0, 1, 2, 3, 4, 5, 6, 7, 8, 7, 6, 5, 4, 3, 2, 1],
    );

    for (var step = 0; step <= 48; step++) {
      final glow = WorldThreeLuminaField.glowOpacityAt(
        Duration(milliseconds: step * 100),
        0.2,
      );
      expect(glow, inInclusiveRange(0.84, 0.94));
    }
  });

  test('World 3 lumina-moths remain staggered, sparse, and responsive', () {
    for (
      var second = 0;
      second < WorldThreeLuminaField.cycleSeconds;
      second++
    ) {
      final visibleCreatures = WorldThreeLuminaField.flightSpecs.where((spec) {
        final lifecycle = WorldThreeLuminaField.lifecycleAt(
          Duration(seconds: second),
          spec.phaseOffset,
        );
        return WorldThreeLuminaField.lifecycleOpacity(lifecycle.progress) > 0;
      }).length;
      expect(visibleCreatures, inInclusiveRange(1, 2));
    }

    for (
      var index = 0;
      index < WorldThreeLuminaField.flightSpecs.length;
      index++
    ) {
      final spec = WorldThreeLuminaField.flightSpecs[index];
      for (var step = 0; step <= 10; step++) {
        final small = WorldThreeLuminaField.positionForProgress(
          spec,
          step / 10,
          390,
          700,
          1,
        );
        final large = WorldThreeLuminaField.positionForProgress(
          spec,
          step / 10,
          780,
          1400,
          1,
        );

        expect(large.dx, closeTo(small.dx * 2, 0.001));
        expect(large.dy, closeTo(small.dy * 2, 0.001));
        if (index == 0) {
          expect(small.dx / 390, lessThan(0.24));
        } else {
          expect(small.dx / 390, greaterThan(0.82));
        }
      }
    }
  });

  testWidgets('each completed level keeps its building on a separate plot', (
    WidgetTester tester,
  ) async {
    final player = const PlayerModel(
      completedLevelIds: {'w1_l1', 'w1_l2', 'w1_l3', 'w1_l4', 'w1_l5'},
      buildingStages: {
        'hut_w1_l1': 4,
        'hut_w1_l2': 4,
        'hut_w1_l3': 4,
        'hut_w1_l4': 4,
        'hut_w1_l5': 4,
      },
    );
    SharedPreferences.setMockInitialValues({'player_data': player.serialize()});

    final provider = GameProvider();
    while (provider.isLoading) {
      await tester.pump();
    }

    await tester.pumpWidget(
      ChangeNotifierProvider<GameProvider>.value(
        value: provider,
        child: const MaterialApp(
          home: Scaffold(
            body: VillageBuildingsOverlay(
              worldId: 'world_1',
              width: 390,
              height: 844,
            ),
          ),
        ),
      ),
    );

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName ==
                'assets/images/world1_level1_complete.png',
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName ==
                'assets/images/world1_level2_complete.png',
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName ==
                'assets/images/world1_level3_complete.png',
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName ==
                'assets/images/world1_level4_complete.png',
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName ==
                'assets/images/world1_level5_complete.png',
      ),
      findsOneWidget,
    );

    await tester.pumpWidget(const SizedBox.shrink());
    provider.dispose();
  });

  testWidgets('completed Level 6 cabin appears on the snowy World 2 plot', (
    WidgetTester tester,
  ) async {
    final player = const PlayerModel(
      completedLevelIds: {'w1_l5', 'w2_l1'},
      buildingStages: {'hut_w2_l1': 4},
    );
    SharedPreferences.setMockInitialValues({'player_data': player.serialize()});

    final provider = GameProvider();
    while (provider.isLoading) {
      await tester.pump();
    }

    await tester.pumpWidget(
      ChangeNotifierProvider<GameProvider>.value(
        value: provider,
        child: const MaterialApp(
          home: Scaffold(
            body: VillageBuildingsOverlay(
              worldId: 'world_2',
              width: 390,
              height: 693,
            ),
          ),
        ),
      ),
    );

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName ==
                'assets/images/world2_level6_complete.png',
      ),
      findsOneWidget,
    );

    await tester.pumpWidget(const SizedBox.shrink());
    provider.dispose();
  });

  testWidgets('completed Level 7 watermill appears on its own World 2 plot', (
    WidgetTester tester,
  ) async {
    final player = const PlayerModel(
      completedLevelIds: {'w1_l5', 'w2_l1', 'w2_l2'},
      buildingStages: {'hut_w2_l2': 4},
    );
    SharedPreferences.setMockInitialValues({'player_data': player.serialize()});

    final provider = GameProvider();
    while (provider.isLoading) {
      await tester.pump();
    }

    await tester.pumpWidget(
      ChangeNotifierProvider<GameProvider>.value(
        value: provider,
        child: const MaterialApp(
          home: Scaffold(
            body: VillageBuildingsOverlay(
              worldId: 'world_2',
              width: 390,
              height: 693,
            ),
          ),
        ),
      ),
    );

    expect(
      find.image(const AssetImage('assets/images/world2_level7_complete.png')),
      findsOneWidget,
    );
    expect(
      find.image(const AssetImage('assets/images/world2_level6_complete.png')),
      findsNothing,
    );

    await tester.pumpWidget(const SizedBox.shrink());
    provider.dispose();
  });

  testWidgets('completed Level 8 observatory appears on its own World 2 plot', (
    WidgetTester tester,
  ) async {
    final player = const PlayerModel(
      completedLevelIds: {'w1_l5', 'w2_l1', 'w2_l2', 'w2_l3'},
      buildingStages: {'hut_w2_l3': 4},
    );
    SharedPreferences.setMockInitialValues({'player_data': player.serialize()});

    final provider = GameProvider();
    while (provider.isLoading) {
      await tester.pump();
    }

    await tester.pumpWidget(
      ChangeNotifierProvider<GameProvider>.value(
        value: provider,
        child: const MaterialApp(
          home: Scaffold(
            body: VillageBuildingsOverlay(
              worldId: 'world_2',
              width: 390,
              height: 693,
            ),
          ),
        ),
      ),
    );

    expect(
      find.image(const AssetImage('assets/images/world2_level8_complete.png')),
      findsOneWidget,
    );
    expect(
      find.image(const AssetImage('assets/images/world2_level7_complete.png')),
      findsNothing,
    );

    await tester.pumpWidget(const SizedBox.shrink());
    provider.dispose();
  });

  testWidgets('completed Level 9 guildhall appears on its own World 2 plot', (
    WidgetTester tester,
  ) async {
    final player = const PlayerModel(
      completedLevelIds: {'w1_l5', 'w2_l1', 'w2_l2', 'w2_l3', 'w2_l4'},
      buildingStages: {'hut_w2_l4': 4},
    );
    SharedPreferences.setMockInitialValues({'player_data': player.serialize()});

    final provider = GameProvider();
    while (provider.isLoading) {
      await tester.pump();
    }

    await tester.pumpWidget(
      ChangeNotifierProvider<GameProvider>.value(
        value: provider,
        child: const MaterialApp(
          home: Scaffold(
            body: VillageBuildingsOverlay(
              worldId: 'world_2',
              width: 390,
              height: 693,
            ),
          ),
        ),
      ),
    );

    expect(
      find.image(const AssetImage('assets/images/world2_level9_complete.png')),
      findsOneWidget,
    );
    expect(
      find.image(const AssetImage('assets/images/world2_level8_complete.png')),
      findsNothing,
    );

    await tester.pumpWidget(const SizedBox.shrink());
    provider.dispose();
  });

  testWidgets('all five completed World 2 buildings form the snowy city', (
    WidgetTester tester,
  ) async {
    final player = const PlayerModel(
      completedLevelIds: {'w1_l5', 'w2_l1', 'w2_l2', 'w2_l3', 'w2_l4', 'w2_l5'},
      buildingStages: {
        'hut_w2_l1': 4,
        'hut_w2_l2': 4,
        'hut_w2_l3': 4,
        'hut_w2_l4': 4,
        'hut_w2_l5': 4,
      },
    );
    SharedPreferences.setMockInitialValues({'player_data': player.serialize()});

    final provider = GameProvider();
    while (provider.isLoading) {
      await tester.pump();
    }

    await tester.pumpWidget(
      ChangeNotifierProvider<GameProvider>.value(
        value: provider,
        child: const MaterialApp(
          home: Scaffold(
            body: VillageBuildingsOverlay(
              worldId: 'world_2',
              width: 390,
              height: 693,
            ),
          ),
        ),
      ),
    );

    for (final level in [6, 7, 8, 9, 10]) {
      expect(
        find.image(
          AssetImage('assets/images/world2_level${level}_complete.png'),
        ),
        findsOneWidget,
      );
    }

    await tester.pumpWidget(const SizedBox.shrink());
    provider.dispose();
  });

  test('World 3 Level 11 cottage stages save independently', () async {
    final player = const PlayerModel(
      woodLogs: 4,
      completedLevelIds: {'w2_l5', 'w3_l1'},
      buildingStages: {'hut_w2_l5': 4},
    );
    SharedPreferences.setMockInitialValues({'player_data': player.serialize()});
    final provider = GameProvider();
    while (provider.isLoading) {
      await Future<void>.delayed(Duration.zero);
    }
    final level = provider.worlds.last.levels.first;
    expect(provider.supportsLevelBuilding(level), isTrue);
    expect(
      provider.supportsLevelBuilding(provider.worlds.last.levels[1]),
      isTrue,
    );
    for (var stage = 0; stage <= 4; stage++) {
      final asset = FoundationBuilderScreen.imageForProgress(
        progress: stage,
        levelNumber: 11,
        worldId: 'world_3',
      );
      expect(
        asset,
        stage == 4
            ? 'assets/images/world3_level11_complete.png'
            : 'assets/images/world3_level11_stage$stage.png',
      );
      final sprite = image.decodePng(File(asset).readAsBytesSync())!;
      expect(sprite.getPixel(0, 0).a, 0);
      expect(provider.levelHouseStage(level), stage);
      if (stage < 4) {
        expect(provider.advanceLevelHouseConstruction(level), isTrue);
      }
    }
    expect(provider.player.buildingStages['hut_w2_l5'], 4);
    expect(provider.player.woodLogs, 0);
    await provider.saveProgress();
    final prefs = await SharedPreferences.getInstance();
    final saved = PlayerModel.deserialize(prefs.getString('player_data')!);
    expect(saved.buildingStages['hut_w3_l1'], 4);
    provider.dispose();
  });

  testWidgets('World 3 completed cottage appears on the first plot', (
    tester,
  ) async {
    final player = const PlayerModel(buildingStages: {'hut_w3_l1': 4});
    SharedPreferences.setMockInitialValues({'player_data': player.serialize()});
    final provider = GameProvider();
    while (provider.isLoading) {
      await tester.pump();
    }
    await tester.pumpWidget(
      ChangeNotifierProvider<GameProvider>.value(
        value: provider,
        child: const MaterialApp(
          home: Scaffold(
            body: VillageBuildingsOverlay(
              worldId: 'world_3',
              width: 390,
              height: 695,
            ),
          ),
        ),
      ),
    );
    expect(
      find.image(const AssetImage('assets/images/world3_level11_complete.png')),
      findsOneWidget,
    );
    expect(
      find.image(const AssetImage('assets/images/world1_level1_complete.png')),
      findsNothing,
    );
    await tester.pumpWidget(const SizedBox.shrink());
    provider.dispose();
  });

  test('World 3 Level 12 sanctuary stages save independently', () async {
    final player = const PlayerModel(
      woodLogs: 4,
      completedLevelIds: {'w3_l1', 'w3_l2'},
      buildingStages: {'hut_w3_l1': 4},
    );
    SharedPreferences.setMockInitialValues({'player_data': player.serialize()});
    final provider = GameProvider();
    while (provider.isLoading) {
      await Future<void>.delayed(Duration.zero);
    }
    final level = provider.worlds.last.levels[1];
    expect(provider.supportsLevelBuilding(level), isTrue);
    for (var stage = 0; stage <= 4; stage++) {
      final asset = FoundationBuilderScreen.imageForProgress(
        progress: stage,
        levelNumber: 12,
        worldId: 'world_3',
      );
      expect(
        asset,
        stage == 4
            ? 'assets/images/world3_level12_complete.png'
            : 'assets/images/world3_level12_stage$stage.png',
      );
      final sprite = image.decodePng(File(asset).readAsBytesSync())!;
      expect(sprite.getPixel(0, 0).a, 0);
      expect(provider.levelHouseStage(level), stage);
      if (stage < 4) {
        expect(provider.advanceLevelHouseConstruction(level), isTrue);
      }
    }
    expect(provider.advanceLevelHouseConstruction(level), isFalse);
    expect(provider.player.woodLogs, 0);
    expect(provider.player.buildingStages['hut_w3_l1'], 4);
    await provider.saveProgress();
    final prefs = await SharedPreferences.getInstance();
    final saved = PlayerModel.deserialize(prefs.getString('player_data')!);
    expect(saved.buildingStages['hut_w3_l2'], 4);
    expect(saved.buildingStages['hut_w3_l1'], 4);
    provider.dispose();
  });

  testWidgets('World 3 sanctuary appears independently on the second plot', (
    tester,
  ) async {
    for (final cottageStage in [0, 4]) {
      final player = PlayerModel(
        buildingStages: {'hut_w3_l1': cottageStage, 'hut_w3_l2': 4},
      );
      SharedPreferences.setMockInitialValues({
        'player_data': player.serialize(),
      });
      final provider = GameProvider();
      while (provider.isLoading) {
        await tester.pump();
      }
      await tester.pumpWidget(
        ChangeNotifierProvider<GameProvider>.value(
          value: provider,
          child: const MaterialApp(
            home: Scaffold(
              body: VillageBuildingsOverlay(
                worldId: 'world_3',
                width: 390,
                height: 695,
              ),
            ),
          ),
        ),
      );
      final sanctuary = find.image(
        const AssetImage('assets/images/world3_level12_complete.png'),
      );
      expect(sanctuary, findsOneWidget);
      final position = tester.widget<Positioned>(
        find.ancestor(of: sanctuary, matching: find.byType(Positioned)),
      );
      expect(position.left, closeTo(390 * 0.360, 0.001));
      expect(position.top, closeTo(695 * 0.608, 0.001));
      expect(
        find.image(
          const AssetImage('assets/images/world3_level11_complete.png'),
        ),
        cottageStage == 4 ? findsOneWidget : findsNothing,
      );
      await tester.pumpWidget(const SizedBox.shrink());
      provider.dispose();
    }
  });

  test('Level 13 introduces simple ratios and unit rates', () async {
    final level = WorldRepository.getAllWorlds().last.levels[2];
    expect(level.id, 'w3_l3');
    expect(level.levelNumber, 13);
    expect(level.questions, hasLength(5));
    expect(level.questions.map((q) => q.id).toSet(), hasLength(5));
    // Independently checked results of the five math problems.
    expect(level.questions.map((q) => q.options[q.correctAnswerIndex]), [
      '6',
      '2:3',
      '4',
      '20',
      '5',
    ]);
    for (final question in level.questions) {
      expect(question.options.toSet(), hasLength(4));
      expect(question.explanationSteps, isNotEmpty);
      expect(question.hintText, isNotEmpty);
    }
    expect(
      LevelCheatCodes.resolveLevel(
        'MQ-LVL-13',
        WorldRepository.getAllWorlds(),
      )?.id,
      level.id,
    );
    for (final completedPrevious in [false, true]) {
      final earlierLevels = WorldRepository.getAllWorlds()
          .where((world) => world.worldNumber < 3)
          .expand((world) => world.levels);
      final player = PlayerModel(
        unlockedWorldIds: {'world_1', 'world_2', 'world_3'},
        completedLevelIds: {
          ...earlierLevels.map((level) => level.id),
          if (completedPrevious) 'w3_l1',
          if (completedPrevious) 'w3_l2',
        },
        levelStars: {
          for (final level in earlierLevels) level.id: 3,
          if (completedPrevious) 'w3_l1': 3,
          if (completedPrevious) 'w3_l2': 3,
        },
      );
      SharedPreferences.setMockInitialValues({
        'player_data': player.serialize(),
      });
      final provider = GameProvider();
      while (provider.isLoading) {
        await Future<void>.delayed(Duration.zero);
      }
      expect(provider.isLevelUnlocked(level), completedPrevious);
      provider.dispose();
    }
  });

  test('World 3 Level 13 observatory stages save independently', () async {
    final player = const PlayerModel(
      woodLogs: 4,
      completedLevelIds: {'w3_l1', 'w3_l2', 'w3_l3'},
      buildingStages: {'hut_w3_l1': 4, 'hut_w3_l2': 4},
    );
    SharedPreferences.setMockInitialValues({'player_data': player.serialize()});
    final provider = GameProvider();
    while (provider.isLoading) {
      await Future<void>.delayed(Duration.zero);
    }
    final level = provider.worlds.last.levels[2];
    expect(provider.supportsLevelBuilding(level), isTrue);
    for (var stage = 0; stage <= 4; stage++) {
      final asset = FoundationBuilderScreen.imageForProgress(
        progress: stage,
        levelNumber: 13,
        worldId: 'world_3',
      );
      expect(
        asset,
        stage == 4
            ? 'assets/images/world3_level13_complete.png'
            : 'assets/images/world3_level13_stage$stage.png',
      );
      final sprite = image.decodePng(File(asset).readAsBytesSync())!;
      expect(sprite.getPixel(0, 0).a, 0);
      expect(provider.levelHouseStage(level), stage);
      if (stage < 4) {
        expect(provider.advanceLevelHouseConstruction(level), isTrue);
      }
    }
    expect(provider.advanceLevelHouseConstruction(level), isFalse);
    expect(provider.player.woodLogs, 0);
    await provider.saveProgress();
    final prefs = await SharedPreferences.getInstance();
    final saved = PlayerModel.deserialize(prefs.getString('player_data')!);
    expect(saved.buildingStages['hut_w3_l1'], 4);
    expect(saved.buildingStages['hut_w3_l2'], 4);
    expect(saved.buildingStages['hut_w3_l3'], 4);
    provider.dispose();
  });

  testWidgets('World 3 observatory appears independently on the third plot', (
    tester,
  ) async {
    for (final previousStage in [0, 4]) {
      final player = PlayerModel(
        buildingStages: {
          'hut_w3_l1': previousStage,
          'hut_w3_l2': previousStage,
          'hut_w3_l3': 4,
        },
      );
      SharedPreferences.setMockInitialValues({
        'player_data': player.serialize(),
      });
      final provider = GameProvider();
      while (provider.isLoading) {
        await tester.pump();
      }
      await tester.pumpWidget(
        ChangeNotifierProvider<GameProvider>.value(
          value: provider,
          child: const MaterialApp(
            home: Scaffold(
              body: VillageBuildingsOverlay(
                worldId: 'world_3',
                width: 390,
                height: 695,
              ),
            ),
          ),
        ),
      );
      expect(
        find.image(
          const AssetImage('assets/images/world3_level13_complete.png'),
        ),
        findsOneWidget,
      );
      for (final number in [11, 12]) {
        expect(
          find.image(
            AssetImage('assets/images/world3_level${number}_complete.png'),
          ),
          previousStage == 4 ? findsOneWidget : findsNothing,
        );
      }
      await tester.pumpWidget(const SizedBox.shrink());
      provider.dispose();
    }
  });

  testWidgets(
    'Level 13 builder fits a phone and shows the supplied hut start',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      SharedPreferences.setMockInitialValues({});
      final provider = GameProvider();
      while (provider.isLoading) {
        await tester.pump();
      }
      await tester.pumpWidget(
        ChangeNotifierProvider<GameProvider>.value(
          value: provider,
          child: MaterialApp(
            home: FoundationBuilderScreen(
              level: provider.worlds.last.levels[2],
            ),
          ),
        ),
      );
      await tester.pump();
      expect(
        find.image(const AssetImage('assets/images/world3_level13_stage0.png')),
        findsOneWidget,
      );
      expect(find.textContaining('Small forest hut'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      provider.dispose();
    },
  );

  test('Level 14 introduces variables and one-step equations', () async {
    final world = WorldRepository.getAllWorlds().last;
    final level = world.levels[3];
    expect(level.id, 'w3_l4');
    expect(level.levelNumber, 14);
    expect(level.questions, hasLength(5));
    expect(level.questions.map((q) => q.id).toSet(), hasLength(5));
    expect(level.questions.map((q) => q.options[q.correctAnswerIndex]), [
      '5',
      '13',
      '6',
      '20',
      '11',
    ]);
    for (final question in level.questions) {
      expect(question.options.toSet(), hasLength(4));
      expect(question.explanationSteps, isNotEmpty);
      expect(question.hintText, isNotEmpty);
    }
    expect(
      LevelCheatCodes.resolveLevel(
        'MQ-LVL-14',
        WorldRepository.getAllWorlds(),
      )?.id,
      level.id,
    );
    final earlierLevels = WorldRepository.getAllWorlds()
        .where((world) => world.worldNumber < 3)
        .expand((world) => world.levels);
    for (final completedPrevious in [false, true]) {
      final player = PlayerModel(
        completedLevelIds: {
          ...earlierLevels.map((level) => level.id),
          'w3_l1',
          'w3_l2',
          if (completedPrevious) 'w3_l3',
        },
        levelStars: {
          for (final level in earlierLevels) level.id: 3,
          'w3_l1': 3,
          'w3_l2': 3,
          if (completedPrevious) 'w3_l3': 3,
        },
      );
      SharedPreferences.setMockInitialValues({
        'player_data': player.serialize(),
      });
      final provider = GameProvider();
      while (provider.isLoading) {
        await Future<void>.delayed(Duration.zero);
      }
      expect(provider.isLevelUnlocked(level), completedPrevious);
      provider.dispose();
    }
  });

  test(
    'Level 14 construction persists without changing earlier buildings',
    () async {
      final player = const PlayerModel(
        woodLogs: 4,
        completedLevelIds: {'w3_l4'},
        buildingStages: {'hut_w3_l1': 4, 'hut_w3_l2': 4, 'hut_w3_l3': 4},
      );
      SharedPreferences.setMockInitialValues({
        'player_data': player.serialize(),
      });
      final provider = GameProvider();
      while (provider.isLoading) {
        await Future<void>.delayed(Duration.zero);
      }
      final level = provider.worlds.last.levels[3];
      expect(provider.supportsLevelBuilding(level), isTrue);
      for (var stage = 0; stage <= 4; stage++) {
        final asset = FoundationBuilderScreen.imageForProgress(
          progress: stage,
          levelNumber: 14,
          worldId: 'world_3',
        );
        expect(
          asset,
          stage == 4
              ? 'assets/images/world3_level14_complete.png'
              : 'assets/images/world3_level14_stage$stage.png',
        );
        final sprite = image.decodePng(File(asset).readAsBytesSync())!;
        for (final x in [0, sprite.width - 1]) {
          for (final y in [0, sprite.height - 1]) {
            // Allow a single alpha quantization step in generated edge pixels.
            expect(sprite.getPixel(x, y).a, lessThanOrEqualTo(1));
          }
        }
        expect(provider.levelHouseStage(level), stage);
        if (stage < 4) {
          expect(provider.advanceLevelHouseConstruction(level), isTrue);
        }
      }
      expect(provider.advanceLevelHouseConstruction(level), isFalse);
      expect(provider.player.woodLogs, 0);
      await provider.saveProgress();
      final prefs = await SharedPreferences.getInstance();
      final saved = PlayerModel.deserialize(prefs.getString('player_data')!);
      for (final number in [1, 2, 3, 4]) {
        expect(saved.buildingStages['hut_w3_l$number'], 4);
      }
      provider.dispose();
    },
  );

  testWidgets('World 3 manor appears independently on the fourth plot', (
    tester,
  ) async {
    for (final previousStage in [0, 4]) {
      final player = PlayerModel(
        buildingStages: {
          for (final number in [1, 2, 3]) 'hut_w3_l$number': previousStage,
          'hut_w3_l4': 4,
        },
      );
      SharedPreferences.setMockInitialValues({
        'player_data': player.serialize(),
      });
      final provider = GameProvider();
      while (provider.isLoading) {
        await tester.pump();
      }
      await tester.pumpWidget(
        ChangeNotifierProvider<GameProvider>.value(
          value: provider,
          child: const MaterialApp(
            home: Scaffold(
              body: VillageBuildingsOverlay(
                worldId: 'world_3',
                width: 390,
                height: 695,
              ),
            ),
          ),
        ),
      );
      expect(
        find.image(
          const AssetImage('assets/images/world3_level14_complete.png'),
        ),
        findsOneWidget,
      );
      for (final number in [11, 12, 13]) {
        expect(
          find.image(
            AssetImage('assets/images/world3_level${number}_complete.png'),
          ),
          previousStage == 4 ? findsOneWidget : findsNothing,
        );
      }
      await tester.pumpWidget(const SizedBox.shrink());
      provider.dispose();
    }
  });

  testWidgets('Level 14 builder fits a phone at the start and completion', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final stage in [0, 4]) {
      final player = PlayerModel(buildingStages: {'hut_w3_l4': stage});
      SharedPreferences.setMockInitialValues({
        'player_data': player.serialize(),
      });
      final provider = GameProvider();
      while (provider.isLoading) {
        await tester.pump();
      }
      await tester.pumpWidget(
        ChangeNotifierProvider<GameProvider>.value(
          value: provider,
          child: MaterialApp(
            home: FoundationBuilderScreen(
              level: provider.worlds.last.levels[3],
            ),
          ),
        ),
      );
      await tester.pump();
      expect(
        find.image(
          AssetImage(
            stage == 4
                ? 'assets/images/world3_level14_complete.png'
                : 'assets/images/world3_level14_stage0.png',
          ),
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      provider.dispose();
    }
  });

  test('Level 15 pre-algebra finale unlocks after Level 14', () async {
    final worlds = WorldRepository.getAllWorlds();
    final level = worlds.last.levels.last;
    expect(worlds.last.levels.map((level) => level.levelNumber), [
      11,
      12,
      13,
      14,
      15,
    ]);
    expect(level.id, 'w3_l5');
    expect(level.difficulty, 'Intermediate');
    expect(level.questions, hasLength(5));
    expect(level.questions.map((q) => q.id).toSet(), hasLength(5));
    expect(level.questions.map((q) => q.options[q.correctAnswerIndex]), [
      '11',
      '8',
      '4',
      '10',
      '6',
    ]);
    expect(
      worlds.last.levels
          .where((level) => level.levelNumber >= 13)
          .expand((level) => level.questions)
          .every((question) => question.questionText.length <= 45),
      isTrue,
    );
    for (final question in level.questions) {
      expect(question.options.toSet(), hasLength(4));
      expect(question.explanationSteps, isNotEmpty);
      expect(question.hintText, isNotEmpty);
    }
    expect(LevelCheatCodes.resolveLevel('MQ-LVL-15', worlds)?.id, level.id);
    final earlierLevels = worlds
        .expand((world) => world.levels)
        .where((level) => level.levelNumber < 14);
    for (final completedPrevious in [false, true]) {
      final player = PlayerModel(
        woodLogs: 0,
        completedLevelIds: {
          ...earlierLevels.map((level) => level.id),
          if (completedPrevious) 'w3_l4',
        },
        levelStars: {for (final level in earlierLevels) level.id: 3},
      );
      SharedPreferences.setMockInitialValues({
        'player_data': player.serialize(),
      });
      final provider = GameProvider();
      while (provider.isLoading) {
        await Future<void>.delayed(Duration.zero);
      }
      expect(provider.isLevelUnlocked(level), completedPrevious);
      if (completedPrevious) {
        provider.startLevel(level);
        while (!provider.isLevelCompleted) {
          provider.selectAnswer(provider.currentQuestion!.correctAnswerIndex);
          provider.submitAnswer();
          provider.nextQuestion();
        }
        expect(provider.player.completedLevelIds, contains(level.id));
        expect(provider.player.levelStars[level.id], 3);
        expect(provider.player.woodLogs, 5);
        expect(provider.pendingConstructionLevelId, level.id);
        expect(provider.player.currentWorldId, 'world_3');
        expect(provider.player.unlockedWorldIds, isNot(contains('world_4')));
        await provider.saveProgress();
        final prefs = await SharedPreferences.getInstance();
        final saved = PlayerModel.deserialize(prefs.getString('player_data')!);
        expect(saved.completedLevelIds, contains(level.id));
      }
      provider.dispose();
    }
  });

  test('Level 15 construction saves all five stages independently', () async {
    final player = PlayerModel(
      woodLogs: 4,
      completedLevelIds: {'w3_l5'},
      buildingStages: {
        for (final number in [1, 2, 3, 4]) 'hut_w3_l$number': 4,
      },
    );
    SharedPreferences.setMockInitialValues({'player_data': player.serialize()});
    final provider = GameProvider();
    while (provider.isLoading) {
      await Future<void>.delayed(Duration.zero);
    }
    final level = provider.worlds.last.levels.last;
    expect(provider.supportsLevelBuilding(level), isTrue);
    for (var stage = 0; stage <= 4; stage++) {
      final asset = FoundationBuilderScreen.imageForProgress(
        progress: stage,
        levelNumber: 15,
        worldId: 'world_3',
      );
      expect(
        asset,
        stage == 4
            ? 'assets/images/world3_level15_complete.png'
            : 'assets/images/world3_level15_stage$stage.png',
      );
      final sprite = image.decodePng(File(asset).readAsBytesSync())!;
      for (final x in [0, sprite.width - 1]) {
        for (final y in [0, sprite.height - 1]) {
          expect(sprite.getPixel(x, y).a, lessThanOrEqualTo(1));
        }
      }
      expect(provider.levelHouseStage(level), stage);
      if (stage < 4) {
        expect(provider.advanceLevelHouseConstruction(level), isTrue);
      }
    }
    expect(provider.advanceLevelHouseConstruction(level), isFalse);
    expect(provider.player.woodLogs, 0);
    await provider.saveProgress();
    final prefs = await SharedPreferences.getInstance();
    final saved = PlayerModel.deserialize(prefs.getString('player_data')!);
    for (final number in [1, 2, 3, 4, 5]) {
      expect(saved.buildingStages['hut_w3_l$number'], 4);
    }
    provider.dispose();
  });

  testWidgets(
    'Final sanctuary appears independently and completes the World 3 city',
    (tester) async {
      for (final previousStage in [0, 4]) {
        final player = PlayerModel(
          buildingStages: {
            for (final number in [1, 2, 3, 4]) 'hut_w3_l$number': previousStage,
            'hut_w3_l5': 4,
          },
        );
        SharedPreferences.setMockInitialValues({
          'player_data': player.serialize(),
        });
        final provider = GameProvider();
        while (provider.isLoading) {
          await tester.pump();
        }
        await tester.pumpWidget(
          ChangeNotifierProvider<GameProvider>.value(
            value: provider,
            child: const MaterialApp(
              home: Scaffold(
                body: VillageBuildingsOverlay(
                  worldId: 'world_3',
                  width: 390,
                  height: 695,
                ),
              ),
            ),
          ),
        );
        expect(
          find.image(
            const AssetImage('assets/images/world3_level15_complete.png'),
          ),
          findsOneWidget,
        );
        for (final number in [11, 12, 13, 14]) {
          expect(
            find.image(
              AssetImage('assets/images/world3_level${number}_complete.png'),
            ),
            previousStage == 4 ? findsOneWidget : findsNothing,
          );
        }
        await tester.pumpWidget(const SizedBox.shrink());
        provider.dispose();
      }
    },
  );

  testWidgets('Level 15 builder fits a phone at the start and completion', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final stage in [0, 4]) {
      final player = PlayerModel(buildingStages: {'hut_w3_l5': stage});
      SharedPreferences.setMockInitialValues({
        'player_data': player.serialize(),
      });
      final provider = GameProvider();
      while (provider.isLoading) {
        await tester.pump();
      }
      await tester.pumpWidget(
        ChangeNotifierProvider<GameProvider>.value(
          value: provider,
          child: MaterialApp(
            home: FoundationBuilderScreen(
              level: provider.worlds.last.levels.last,
            ),
          ),
        ),
      );
      await tester.pump();
      expect(
        find.image(
          AssetImage(
            stage == 4
                ? 'assets/images/world3_level15_complete.png'
                : 'assets/images/world3_level15_stage0.png',
          ),
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      provider.dispose();
    }
  });

  testWidgets('Math Quest app initializes correctly', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MathQuestApp());
    expect(find.byType(MathQuestApp), findsOneWidget);
  });
}
