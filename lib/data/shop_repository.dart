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
    ];
  }
}
