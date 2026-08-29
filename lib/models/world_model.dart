import 'package:flutter/material.dart';
import 'level_model.dart';

class WorldModel {
  final String id;
  final int worldNumber;
  final String name;
  final String subtitle;
  final String description;
  final String iconEmoji;
  final Color primaryColor;
  final Color secondaryColor;
  final List<LevelModel> levels;
  final int reqStarsToUnlock;
  final bool isUnlockedByDefault;

  const WorldModel({
    required this.id,
    required this.worldNumber,
    required this.name,
    required this.subtitle,
    required this.description,
    required this.iconEmoji,
    required this.primaryColor,
    required this.secondaryColor,
    required this.levels,
    this.reqStarsToUnlock = 0,
    this.isUnlockedByDefault = false,
  });
}
