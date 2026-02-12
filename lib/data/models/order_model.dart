import 'package:restaurant_mobile_app/domain/entities/order_entity.dart';

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.items,
    required super.totalAmount,
    required super.status,
    required super.customerId,
    super.customerName,
    super.customerEmail,
    super.tableNumber,
    required super.orderType,
    required super.orderDate,
    super.inventoryDeduction,
    required super.createdAt,
    required super.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['_id']?.toString() ?? '',
      items:
          (json['items'] as List<dynamic>?)
              ?.map((item) => OrderItemEntity.fromJson(item))
              .toList() ??
          [],
      totalAmount: (json['totalAmount'] as num).toDouble(),
      status: OrderStatus.fromString(json['status'] ?? 'pending'),
      customerId: json['customer'] is String
          ? json['customer']
          : json['customer']?['_id']?.toString() ?? '',
      customerName: json['customer'] is Map<String, dynamic>
          ? json['customer']['name']
          : null,
      customerEmail: json['customer'] is Map<String, dynamic>
          ? json['customer']['email']
          : null,
      tableNumber: json['tableNumber'],
      orderType: OrderType.fromString(json['orderType'] ?? 'dine-in'),
      orderDate: DateTime.parse(json['orderDate']),
      inventoryDeduction: json['inventoryDeduction'] != null
          ? InventoryDeductionEntity.fromJson(json['inventoryDeduction'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
