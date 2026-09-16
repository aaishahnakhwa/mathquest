enum CurrencyType { coins, gems }

enum ShopCategory { avatarHat }

class ShopItemModel {
  final String id;
  final String name;
  final String description;
  final ShopCategory category;
  final int price;
  final CurrencyType currency;
  final String iconEmoji;
  final bool isUnlocked;
  final bool isEquipped;

  const ShopItemModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.currency,
    required this.iconEmoji,
    this.isUnlocked = false,
    this.isEquipped = false,
  });

  ShopItemModel copyWith({bool? isUnlocked, bool? isEquipped}) {
    return ShopItemModel(
      id: id,
      name: name,
      description: description,
      category: category,
      price: price,
      currency: currency,
      iconEmoji: iconEmoji,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      isEquipped: isEquipped ?? this.isEquipped,
    );
  }
}
