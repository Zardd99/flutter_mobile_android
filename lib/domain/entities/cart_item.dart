import 'package:equatable/equatable.dart';
import 'package:restaurant_mobile_app/domain/entities/menu_item.dart';

class CartItem extends Equatable {
  final MenuItem menuItem;
  int quantity;
  String? specialInstructions;

  CartItem({
    required this.menuItem,
    this.quantity = 1,
    this.specialInstructions,
  });

  double get total => menuItem.price * quantity;

  CartItem copyWith({int? quantity, String? specialInstructions}) {
    return CartItem(
      menuItem: menuItem,
      quantity: quantity ?? this.quantity,
      specialInstructions: specialInstructions ?? this.specialInstructions,
    );
  }

  @override
  List<Object?> get props => [menuItem.id, quantity, specialInstructions];
}
