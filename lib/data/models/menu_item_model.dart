class MenuItemModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final List<String> dietaryTags;
  final bool availability;
  final int preparationTime;
  final bool chefSpecial;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  MenuItemModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.dietaryTags,
    required this.availability,
    required this.preparationTime,
    required this.chefSpecial,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    return MenuItemModel(
      id: json['_id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      category: json['category']?.toString() ?? '',
      dietaryTags: List<String>.from(json['dietaryTags'] ?? []),
      availability: json['availability'] ?? true,
      preparationTime: json['preparationTime'] ?? 15,
      chefSpecial: json['chefSpecial'] ?? false,
      imageUrl: json['imageUrl']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'dietaryTags': dietaryTags,
      'availability': availability,
      'preparationTime': preparationTime,
      'chefSpecial': chefSpecial,
      if (imageUrl != null) 'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
