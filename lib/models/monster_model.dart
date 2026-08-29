import 'package:flutter/material.dart';

class MonsterModel {
  final String id;
  final String name;
  final String emoji;
  final int maxHp;
  final Color primaryColor;
  final Color secondaryColor;

  const MonsterModel({
    required this.id,
    required this.name,
    required this.emoji,
    this.maxHp = 100,
    required this.primaryColor,
    required this.secondaryColor,
  });

  static MonsterModel getForWorld(String worldId) {
    switch (worldId) {
      case 'world_2':
        return const MonsterModel(
          id: 'm_goblin',
          name: 'Timber Goblin',
          emoji: '👺',
          primaryColor: Color(0xFF15803D),
          secondaryColor: Color(0xFF86EFAC),
        );
      case 'world_3':
        return const MonsterModel(
          id: 'm_golem',
          name: 'Stone Golem',
          emoji: '🪨',
          primaryColor: Color(0xFF475569),
          secondaryColor: Color(0xFFCBD5E1),
        );
      case 'world_4':
        return const MonsterModel(
          id: 'm_drake',
          name: 'Flame Drake',
          emoji: '🐲',
          primaryColor: Color(0xFFDC2626),
          secondaryColor: Color(0xFFFCA5A5),
        );
      case 'world_1':
      default:
        return const MonsterModel(
          id: 'm_slime',
          name: 'Meadow Slime',
          emoji: '🟢',
          primaryColor: Color(0xFF16A34A),
          secondaryColor: Color(0xFF4ADE80),
        );
    }
  }
}
