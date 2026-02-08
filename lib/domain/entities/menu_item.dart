import 'package:equatable/equatable.dart';

class MenuItem extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final String categoryId;
  final String? categoryName;
  final List<String> dietaryTags;
  final bool availability;
  final int preparationTime;
  final bool chefSpecial;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.categoryId,
    this.categoryName,
    required this.dietaryTags,
    required this.availability,
    required this.preparationTime,
    required this.chefSpecial,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    final category = json['category'];

    return MenuItem(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      categoryId: category is String
          ? category
          : category?['_id']?.toString() ?? '',
      categoryName: category is Map<String, dynamic> ? category['name'] : null,
      dietaryTags: List<String>.from(json['dietaryTags'] ?? []),
      availability: json['availability'] ?? true,
      preparationTime: json['preparationTime'] ?? 15,
      chefSpecial: json['chefSpecial'] ?? false,
      imageUrl: json['imageUrl']?.toString() ?? json['image']?.toString(),
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
      if (id.isNotEmpty) '_id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': categoryId,
      'dietaryTags': dietaryTags,
      'availability': availability,
      'preparationTime': preparationTime,
      'chefSpecial': chefSpecial,
      if (imageUrl != null) 'imageUrl': imageUrl,
    };
  }

  MenuItem copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? categoryId,
    String? categoryName,
    List<String>? dietaryTags,
    bool? availability,
    int? preparationTime,
    bool? chefSpecial,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MenuItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      dietaryTags: dietaryTags ?? this.dietaryTags,
      availability: availability ?? this.availability,
      preparationTime: preparationTime ?? this.preparationTime,
      chefSpecial: chefSpecial ?? this.chefSpecial,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    price,
    categoryId,
    categoryName,
    dietaryTags,
    availability,
    preparationTime,
    chefSpecial,
    imageUrl,
    createdAt,
    updatedAt,
  ];
}
