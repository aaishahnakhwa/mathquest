enum BuildingStage {
  unbuilt(0, 'Empty Plot'),
  foundation(1, 'Foundation Laid'),
  structure(2, 'Timber Frame'),
  completed(3, 'Fully Built');

  final int value;
  final String label;
  const BuildingStage(this.value, this.label);

  static BuildingStage fromInt(int value) {
    return BuildingStage.values.firstWhere(
      (e) => e.value == value,
      orElse: () => BuildingStage.unbuilt,
    );
  }
}

class BuildingModel {
  final String id;
  final String name;
  final String description;
  final String iconEmoji;
  final int currentStage;
  final int maxStage;
  final List<String> stageTitles;
  final List<int> coinCosts; // Cost to upgrade to stage 1, 2, 3
  final List<int> woodCosts; // Wood log cost to upgrade to stage 1, 2, 3
  final String perkDescription;

  const BuildingModel({
    required this.id,
    required this.name,
    required this.description,
    required this.iconEmoji,
    this.currentStage = 0,
    this.maxStage = 3,
    required this.stageTitles,
    required this.coinCosts,
    required this.woodCosts,
    required this.perkDescription,
  });

  BuildingStage get stageEnum => BuildingStage.fromInt(currentStage);
  bool get isMaxStage => currentStage >= maxStage;

  int get nextStageCoinCost =>
      !isMaxStage && currentStage < coinCosts.length ? coinCosts[currentStage] : 0;

  int get nextStageWoodCost =>
      !isMaxStage && currentStage < woodCosts.length ? woodCosts[currentStage] : 0;

  String get currentStageTitle => currentStage < stageTitles.length
      ? stageTitles[currentStage]
      : 'Completed';

  String get nextStageTitle => currentStage + 1 < stageTitles.length
      ? stageTitles[currentStage + 1]
      : 'Max Level';

  BuildingModel copyWith({
    int? currentStage,
  }) {
    return BuildingModel(
      id: id,
      name: name,
      description: description,
      iconEmoji: iconEmoji,
      currentStage: currentStage ?? this.currentStage,
      maxStage: maxStage,
      stageTitles: stageTitles,
      coinCosts: coinCosts,
      woodCosts: woodCosts,
      perkDescription: perkDescription,
    );
  }
}
