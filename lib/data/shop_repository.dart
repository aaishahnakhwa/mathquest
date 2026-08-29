import '../models/shop_model.dart';

class ShopRepository {
  static List<ShopItemModel> getDefaultShopItems() {
    return const [
      // Avatar Hats
      ShopItemModel(
        id: 'hat_wizard_starter',
        name: "Scholar's Cap",
        description: 'A classic blue wizard cap imbued with wisdom.',
        category: ShopCategory.avatarHat,
        price: 0,
        currency: CurrencyType.coins,
        iconEmoji: '🎓',
        isUnlocked: true,
        isEquipped: true,
      ),
      ShopItemModel(
        id: 'hat_crown_gold',
        name: 'Golden Crown',
        description: 'Fit for a true Math King or Queen!',
        category: ShopCategory.avatarHat,
        price: 300,
        currency: CurrencyType.coins,
        iconEmoji: '👑',
      ),
      ShopItemModel(
        id: 'hat_viking_helm',
        name: 'Viking Helmet',
        description: 'Conquer math problems with warrior spirit!',
        category: ShopCategory.avatarHat,
        price: 15,
        currency: CurrencyType.gems,
        iconEmoji: '🪖',
      ),

      // Avatar Outfits
      ShopItemModel(
        id: 'outfit_explorer',
        name: 'Adventurer Tunic',
        description: 'Lightweight tunic perfect for traveling meadows.',
        category: ShopCategory.avatarOutfit,
        price: 0,
        currency: CurrencyType.coins,
        iconEmoji: '🥋',
        isUnlocked: true,
        isEquipped: true,
      ),
      ShopItemModel(
        id: 'outfit_royal_robe',
        name: 'Royal Math Cloak',
        description: 'Woven with velvet and gold threads.',
        category: ShopCategory.avatarOutfit,
        price: 250,
        currency: CurrencyType.coins,
        iconEmoji: '🥻',
      ),
      ShopItemModel(
        id: 'outfit_cyber_armor',
        name: 'Cosmic Armor',
        description: 'Shining suit of armor for advanced equation trials.',
        category: ShopCategory.avatarOutfit,
        price: 20,
        currency: CurrencyType.gems,
        iconEmoji: '🛡️',
      ),

      // Accessories
      ShopItemModel(
        id: 'wand_wood',
        name: 'Oak Math Wand',
        description: 'Helps focus your calculation powers.',
        category: ShopCategory.accessory,
        price: 0,
        currency: CurrencyType.coins,
        iconEmoji: '🪄',
        isUnlocked: true,
        isEquipped: true,
      ),
      ShopItemModel(
        id: 'scroll_knowledge',
        name: 'Ancient Scroll',
        description: 'Contains formulas from ancient mathematicians.',
        category: ShopCategory.accessory,
        price: 150,
        currency: CurrencyType.coins,
        iconEmoji: '📜',
      ),

      // Boosts / Map Items
      ShopItemModel(
        id: 'boost_streak_protect',
        name: 'Streak Shield',
        description: 'Protects your daily streak if you miss a day.',
        category: ShopCategory.boost,
        price: 10,
        currency: CurrencyType.gems,
        iconEmoji: '🛡️',
      ),
      ShopItemModel(
        id: 'boost_double_coins',
        name: 'Double Coin Potion',
        description: 'Earn 2x coins for your next 3 levels!',
        category: ShopCategory.boost,
        price: 100,
        currency: CurrencyType.coins,
        iconEmoji: '🧪',
      ),
    ];
  }
}
