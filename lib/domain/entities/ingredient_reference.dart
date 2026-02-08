import 'package:equatable/equatable.dart';

class IngredientReference extends Equatable {
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
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'ingredient': ingredientId, 'quantity': quantity, 'unit': unit};
  }

  @override
  List<Object?> get props => [ingredientId, quantity, unit];
}
