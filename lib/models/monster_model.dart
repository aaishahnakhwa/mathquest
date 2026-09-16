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
      case 'world_3':
        return const MonsterModel(
          id: 'm_crimson_arcanist_zarek',
          name: 'Crimson Arcanist Zarek',
          emoji: '💎',
          primaryColor: Color(0xFF991B1B),
          secondaryColor: Color(0xFFEF4444),
        );
      case 'world_2':
        return const MonsterModel(
          id: 'm_frost_regent_veyr',
          name: 'Frost Regent Veyr',
          emoji: '❄️',
          primaryColor: Color(0xFF1D4ED8),
          secondaryColor: Color(0xFF7DD3FC),
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
