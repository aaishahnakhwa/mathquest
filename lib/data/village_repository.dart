import '../models/building_model.dart';

class VillageRepository {
  static List<BuildingModel> getDefaultBuildings() {
    return [
      const BuildingModel(
        id: 'hut_library',
        name: "Sage's Math Library",
        description: "A cozy place where ancient math knowledge is stored.",
        iconEmoji: "📚",
        currentStage: 0,
        maxStage: 3,
        stageTitles: [
          "Plot Reserved",
          "Wood Log Foundation",
          "Timber Study Room",
          "Grand Royal Library"
        ],
        coinCosts: [50, 120, 250],
        woodCosts: [3, 8, 15],
        perkDescription: "+1 Hint Available in Math Battles",
      ),
      const BuildingModel(
        id: 'hut_forge',
        name: "Math Crafting Forge",
        description: "Craft powerful math tools and gear for your journey.",
        iconEmoji: "🔨",
        currentStage: 0,
        maxStage: 3,
        stageTitles: [
          "Plot Reserved",
          "Stone & Wood Base",
          "Blacksmith Workshop",
          "Master Crafting Forge"
        ],
        coinCosts: [75, 150, 300],
        woodCosts: [5, 10, 20],
        perkDescription: "+10% Bonus Coins on Level Completion",
      ),
      const BuildingModel(
        id: 'hut_observatory',
        name: "Starry Observatory",
        description: "Look up at the cosmos to unlock secret math mysteries.",
        iconEmoji: "🔭",
        currentStage: 0,
        maxStage: 3,
        stageTitles: [
          "Plot Reserved",
          "Log Platform",
          "Telescope Tower",
          "Celestial Observatory"
        ],
        coinCosts: [100, 200, 400],
        woodCosts: [6, 12, 25],
        perkDescription: "Unlocks Free Daily Gems in Village",
      ),
    ];
  }
}
