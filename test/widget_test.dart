import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;
import 'package:math_quest/main.dart';
import 'package:math_quest/data/world_repository.dart';
import 'package:math_quest/models/player_model.dart';
import 'package:math_quest/providers/game_provider.dart';
import 'package:math_quest/screens/adventure_map_screen.dart';
import 'package:math_quest/screens/foundation_builder_screen.dart';
import 'package:math_quest/widgets/ambient_butterfly.dart';
import 'package:math_quest/widgets/ambient_leaf_field.dart';
import 'package:math_quest/widgets/village_buildings_overlay.dart';
import 'package:math_quest/widgets/world_three_lumina_field.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('world repository exposes the three illustrated map worlds', () {
    final worlds = WorldRepository.getAllWorlds();

    expect(worlds.map((world) => world.id), ['world_1', 'world_2', 'world_3']);
    expect(worlds.expand((world) => world.levels), hasLength(12));
    expect(
      worlds
          .expand((world) => world.levels)
          .map((level) => level.worldId)
          .toSet(),
      {'world_1', 'world_2', 'world_3'},
    );
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
    for (var index = 0; index < 2; index++) {
      expect(find.byKey(ValueKey('world-three-lumina-$index')), findsOneWidget);
    }

    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    provider.dispose();
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
        'assets/images/const_stage1.png',
        'assets/images/construction_stage_1.png',
        'assets/images/construction_stage_2.png',
        'assets/images/construction_stage_3.png',
        'assets/images/house_stage1.png',
      ],
    );
    expect(
      FoundationBuilderScreen.imageForProgress(progress: 4, levelNumber: 5),
      'assets/images/house_stage5.png',
    );
    expect(
      FoundationBuilderScreen.imageForProgress(progress: 99, levelNumber: 1),
      'assets/images/house_stage1.png',
    );
  });

  test('level 3 progresses from the level 2 final into its own final', () {
    expect(
      List.generate(
        5,
        (progress) => FoundationBuilderScreen.imageForProgress(
          progress: progress,
          levelNumber: 3,
        ),
      ),
      [
        'assets/images/house_stage2.png',
        'assets/images/level3_construction_1.png',
        'assets/images/level3_construction_2.png',
        'assets/images/level3_construction_3.png',
        'assets/images/house_stage3.png',
      ],
    );
    expect(
      FoundationBuilderScreen.imageForProgress(progress: 99, levelNumber: 3),
      'assets/images/house_stage3.png',
    );
  });

  test('level 4 progresses from the level 3 final into its own final', () {
    expect(
      List.generate(
        5,
        (progress) => FoundationBuilderScreen.imageForProgress(
          progress: progress,
          levelNumber: 4,
        ),
      ),
      [
        'assets/images/house_stage3.png',
        'assets/images/level4_construction_1.png',
        'assets/images/level4_construction_2.png',
        'assets/images/level4_construction_3.png',
        'assets/images/house_stage4.png',
      ],
    );
    expect(
      FoundationBuilderScreen.imageForProgress(progress: 99, levelNumber: 4),
      'assets/images/house_stage4.png',
    );
  });

  test('level 5 progresses from the level 4 final into its own final', () {
    expect(
      List.generate(
        5,
        (progress) => FoundationBuilderScreen.imageForProgress(
          progress: progress,
          levelNumber: 5,
        ),
      ),
      [
        'assets/images/house_stage4.png',
        'assets/images/level5_construction_1.png',
        'assets/images/level5_construction_2.png',
        'assets/images/level5_construction_3.png',
        'assets/images/house_stage5.png',
      ],
    );
    expect(
      FoundationBuilderScreen.imageForProgress(progress: 99, levelNumber: 5),
      'assets/images/house_stage5.png',
    );
  });

  test('new construction sprites have transparent backgrounds', () {
    for (final prefix in [
      'construction_stage',
      'level3_construction',
      'level4_construction',
      'level5_construction',
    ]) {
      for (var stage = 1; stage <= 3; stage++) {
        final bytes = File('assets/images/${prefix}_$stage.png')
            .readAsBytesSync();
        final sprite = image.decodePng(bytes);

        expect(sprite, isNotNull);
        expect(sprite!.numChannels, 4);
        expect(sprite.getPixel(0, 0).a, 0);
      }
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

  testWidgets('completed level house figure appears on its map plot', (
    WidgetTester tester,
  ) async {
    final player = const PlayerModel(
      completedLevelIds: {'w1_l1'},
      buildingStages: {'hut_w1_l1': 4},
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
                'assets/images/house_stage1.png',
      ),
      findsOneWidget,
    );

    await tester.pumpWidget(const SizedBox.shrink());
    provider.dispose();
  });

  testWidgets('Math Quest app initializes correctly', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MathQuestApp());
    expect(find.byType(MathQuestApp), findsOneWidget);
  });
}
