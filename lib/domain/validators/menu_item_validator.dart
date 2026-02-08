import 'package:restaurant_mobile_app/core/errors/failure.dart';
import 'package:restaurant_mobile_app/core/errors/result.dart';

class MenuItemValidator {
  static Result<MenuItemData> validateCreationData({
    required String name,
    required String description,
    required double price,
    required String categoryId,
    required List<String> dietaryTags,
    required int preparationTime,
    bool chefSpecial = false,
    bool availability = true,
  }) {
    final errors = <String>[];

    if (name.isEmpty) {
      errors.add('Name is required');
    } else if (name.length > 100) {
      errors.add('Name cannot exceed 100 characters');
    }

    if (description.isEmpty) {
      errors.add('Description is required');
    } else if (description.length > 500) {
      errors.add('Description cannot exceed 500 characters');
    }

    if (price <= 0) {
      errors.add('Price must be greater than 0');
    } else if (price > 1000) {
      errors.add('Price cannot exceed \$1000');
    }

    if (categoryId.isEmpty) {
      errors.add('Category is required');
    }

    if (preparationTime <= 0) {
      errors.add('Preparation time must be greater than 0');
    } else if (preparationTime > 360) {
      errors.add('Preparation time cannot exceed 6 hours');
    }

    if (errors.isNotEmpty) {
      return ResultFailure(ValidationFailure(errors.join(', ')));
    }

    return Success(
      MenuItemData(
        name: name,
        description: description,
        price: price,
        categoryId: categoryId,
        dietaryTags: dietaryTags,
        preparationTime: preparationTime,
        chefSpecial: chefSpecial,
        availability: availability,
      ),
    );
  }

  static Result<Map<String, dynamic>> validateUpdateData({
    String? name,
    String? description,
    double? price,
    String? categoryId,
    List<String>? dietaryTags,
    int? preparationTime,
    bool? chefSpecial,
    bool? availability,
  }) {
    final errors = <String>[];

    if (name != null) {
      if (name.isEmpty) {
        errors.add('Name cannot be empty');
      } else if (name.length > 100) {
        errors.add('Name cannot exceed 100 characters');
      }
    }

    if (description != null) {
      if (description.isEmpty) {
        errors.add('Description cannot be empty');
      } else if (description.length > 500) {
        errors.add('Description cannot exceed 500 characters');
      }
    }

    if (price != null) {
      if (price <= 0) {
        errors.add('Price must be greater than 0');
      } else if (price > 1000) {
        errors.add('Price cannot exceed \$1000');
      }
    }

    if (preparationTime != null) {
      if (preparationTime <= 0) {
        errors.add('Preparation time must be greater than 0');
      } else if (preparationTime > 360) {
        errors.add('Preparation time cannot exceed 6 hours');
      }
    }

    if (errors.isNotEmpty) {
      return ResultFailure(ValidationFailure(errors.join(', ')));
    }

    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (description != null) data['description'] = description;
    if (price != null) data['price'] = price;
    if (categoryId != null) data['category'] = categoryId;
    if (dietaryTags != null) data['dietaryTags'] = dietaryTags;
    if (preparationTime != null) data['preparationTime'] = preparationTime;
    if (chefSpecial != null) data['chefSpecial'] = chefSpecial;
    if (availability != null) data['availability'] = availability;

    return Success(data);
  }
}

class MenuItemData {
  final String name;
  final String description;
  final double price;
  final String categoryId;
  final List<String> dietaryTags;
  final int preparationTime;
  final bool chefSpecial;
  final bool availability;

  MenuItemData({
    required this.name,
    required this.description,
    required this.price,
    required this.categoryId,
    required this.dietaryTags,
    required this.preparationTime,
    required this.chefSpecial,
    required this.availability,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'category': categoryId,
      'dietaryTags': dietaryTags,
      'preparationTime': preparationTime,
      'chefSpecial': chefSpecial,
      'availability': availability,
    };
  }
}
