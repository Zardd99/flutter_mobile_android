class MenuItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String categoryId;
  final String? categoryName;
  final List<IngredientReference> ingredientReferences;
  final List<String> dietaryTags;
  final bool availability;
  final int preparationTime;
  final bool chefSpecial;
  final double averageRating;
  final int reviewCount;
  final String? imageUrl;
  final double? costPrice;
  final double? profitMargin;

  const MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.categoryId,
    this.categoryName,
    required this.ingredientReferences,
    required this.dietaryTags,
    required this.availability,
    required this.preparationTime,
    required this.chefSpecial,
    required this.averageRating,
    required this.reviewCount,
    this.imageUrl,
    this.costPrice,
    this.profitMargin,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    final category = json['category'];

    return MenuItem(
      id: json['_id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] as num).toDouble(),
      categoryId: category is String
          ? category
          : category?['_id']?.toString() ?? '',
      categoryName: category is Map<String, dynamic> ? category['name'] : null,
      ingredientReferences:
          (json['ingredientReferences'] as List<dynamic>?)
              ?.map((item) => IngredientReference.fromJson(item))
              .toList() ??
          [],
      dietaryTags:
          (json['dietaryTags'] as List<dynamic>?)
              ?.map((item) => item.toString())
              .toList() ??
          [],
      availability: json['availability'] ?? true,
      preparationTime: json['preparationTime'] ?? 15,
      chefSpecial: json['chefSpecial'] ?? false,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] ?? 0,
      imageUrl: json['imageUrl']?.toString(),
      costPrice: (json['costPrice'] as num?)?.toDouble(),
      profitMargin: (json['profitMargin'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': categoryId,
      'ingredientReferences': ingredientReferences
          .map((e) => e.toJson())
          .toList(),
      'dietaryTags': dietaryTags,
      'availability': availability,
      'preparationTime': preparationTime,
      'chefSpecial': chefSpecial,
      'averageRating': averageRating,
      'reviewCount': reviewCount,
      'imageUrl': imageUrl,
      'costPrice': costPrice,
      'profitMargin': profitMargin,
    };
  }
}

class IngredientReference {
  final String ingredientId;
  final double quantity;
  final String unit;

  const IngredientReference({
    required this.ingredientId,
    required this.quantity,
    required this.unit,
  });

  factory IngredientReference.fromJson(Map<String, dynamic> json) {
    return IngredientReference(
      ingredientId:
          json['ingredient']?.toString() ??
          json['ingredientId']?.toString() ??
          '',
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'ingredient': ingredientId, 'quantity': quantity, 'unit': unit};
  }
}
