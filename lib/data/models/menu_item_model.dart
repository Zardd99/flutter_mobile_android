  import 'package:restaurant_mobile_app/domain/entities/menu_item.dart';

  class MenuItemModel extends MenuItem {
    MenuItemModel({
      required super.id,
      required super.name,
      required super.description,
      required super.price,
      required super.categoryId,
      super.categoryName,
      required super.ingredientReferences,
      required super.dietaryTags,
      required super.availability,
      required super.preparationTime,
      required super.chefSpecial,
      required super.averageRating,
      required super.reviewCount,
      super.imageUrl,
      super.costPrice,
      super.profitMargin,
    });

    factory MenuItemModel.fromJson(Map<String, dynamic> json) {
      final category = json['category'];

      return MenuItemModel(
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

    @override
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
