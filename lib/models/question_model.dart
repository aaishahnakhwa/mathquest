class QuestionModel {
  final String id;
  final String topic;
  final String difficulty; // Beginner, Intermediate, Advanced
  final String questionText;
  final List<String> options;
  final int correctAnswerIndex;
  final List<String> explanationSteps;
  final String hintText;
  final int xpReward;
  final int coinReward;
  final int gemReward;

  const QuestionModel({
    required this.id,
    required this.topic,
    required this.difficulty,
    required this.questionText,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanationSteps,
    required this.hintText,
    this.xpReward = 25,
    this.coinReward = 10,
    this.gemReward = 1,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'topic': topic,
        'difficulty': difficulty,
        'questionText': questionText,
        'options': options,
        'correctAnswerIndex': correctAnswerIndex,
        'explanationSteps': explanationSteps,
        'hintText': hintText,
        'xpReward': xpReward,
        'coinReward': coinReward,
        'gemReward': gemReward,
      };

  factory QuestionModel.fromJson(Map<String, dynamic> json) => QuestionModel(
        id: json['id'] as String,
        topic: json['topic'] as String,
        difficulty: json['difficulty'] as String,
        questionText: json['questionText'] as String,
        options: List<String>.from(json['options'] as List),
        correctAnswerIndex: json['correctAnswerIndex'] as int,
        explanationSteps: List<String>.from(json['explanationSteps'] as List),
        hintText: json['hintText'] as String,
        xpReward: (json['xpReward'] as int?) ?? 25,
        coinReward: (json['coinReward'] as int?) ?? 10,
        gemReward: (json['gemReward'] as int?) ?? 1,
      );
}
