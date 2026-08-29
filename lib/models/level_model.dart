import 'question_model.dart';

class LevelModel {
  final String id;
  final String worldId;
  final int levelNumber;
  final String title;
  final String topic;
  final String difficulty; // Beginner, Intermediate, Advanced
  final List<QuestionModel> questions;
  final int reqStarsToUnlock;
  final String iconEmoji;

  const LevelModel({
    required this.id,
    required this.worldId,
    required this.levelNumber,
    required this.title,
    required this.topic,
    required this.difficulty,
    required this.questions,
    this.reqStarsToUnlock = 0,
    this.iconEmoji = '⭐',
  });
}
