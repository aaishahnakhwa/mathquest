import 'package:flutter/foundation.dart';

import '../models/level_model.dart';
import '../models/world_model.dart';

class LevelCheatCode {
  final String code;
  final String levelId;
  final String destination;

  const LevelCheatCode({
    required this.code,
    required this.levelId,
    required this.destination,
  });
}

class LevelCheatCodes {
  const LevelCheatCodes._();

  static const bool isEnabled =
      !kReleaseMode || bool.fromEnvironment('ENABLE_TEST_CHEATS');

  static const List<LevelCheatCode> all = [
    LevelCheatCode(
      code: 'MQ-LVL-01',
      levelId: 'w1_l1',
      destination: 'World 1 · Level 1',
    ),
    LevelCheatCode(
      code: 'MQ-LVL-02',
      levelId: 'w1_l2',
      destination: 'World 1 · Level 2',
    ),
    LevelCheatCode(
      code: 'MQ-LVL-03',
      levelId: 'w1_l3',
      destination: 'World 1 · Level 3',
    ),
    LevelCheatCode(
      code: 'MQ-LVL-04',
      levelId: 'w1_l4',
      destination: 'World 1 · Level 4',
    ),
    LevelCheatCode(
      code: 'MQ-LVL-05',
      levelId: 'w1_l5',
      destination: 'World 1 · Level 5',
    ),
    LevelCheatCode(
      code: 'MQ-LVL-06',
      levelId: 'w2_l1',
      destination: 'World 2 · Level 6',
    ),
    LevelCheatCode(
      code: 'MQ-LVL-07',
      levelId: 'w2_l2',
      destination: 'World 2 · Level 7',
    ),
    LevelCheatCode(
      code: 'MQ-LVL-08',
      levelId: 'w2_l3',
      destination: 'World 2 · Level 8',
    ),
    LevelCheatCode(
      code: 'MQ-LVL-09',
      levelId: 'w2_l4',
      destination: 'World 2 · Level 9',
    ),
    LevelCheatCode(
      code: 'MQ-LVL-10',
      levelId: 'w2_l5',
      destination: 'World 2 · Level 10',
    ),
    LevelCheatCode(
      code: 'MQ-LVL-11',
      levelId: 'w3_l1',
      destination: 'World 3 · Level 11',
    ),
    LevelCheatCode(
      code: 'MQ-LVL-12',
      levelId: 'w3_l2',
      destination: 'World 3 · Level 12',
    ),
    LevelCheatCode(
      code: 'MQ-LVL-13',
      levelId: 'w3_l3',
      destination: 'World 3 · Level 13',
    ),
    LevelCheatCode(
      code: 'MQ-LVL-14',
      levelId: 'w3_l4',
      destination: 'World 3 · Level 14',
    ),
    LevelCheatCode(
      code: 'MQ-LVL-15',
      levelId: 'w3_l5',
      destination: 'World 3 · Level 15',
    ),
  ];

  static String normalize(String value) {
    var normalized = value.trim().toUpperCase().replaceAll(
      RegExp(r'[\s_]+'),
      '-',
    );
    while (normalized.contains('--')) {
      normalized = normalized.replaceAll('--', '-');
    }
    return normalized;
  }

  static LevelCheatCode? find(String input) {
    final normalized = normalize(input);
    for (final entry in all) {
      if (entry.code == normalized) return entry;
    }
    return null;
  }

  static LevelModel? resolveLevel(String input, Iterable<WorldModel> worlds) {
    final entry = find(input);
    if (entry == null) return null;

    for (final world in worlds) {
      for (final level in world.levels) {
        if (level.id == entry.levelId) return level;
      }
    }
    return null;
  }
}
