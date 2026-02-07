import 'package:restaurant_mobile_app/domain/entities/order.dart';

class OrderModel extends Order {
  OrderModel({
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
    final customer = json['customer'];

    return OrderModel(
      id: json['_id']?.toString() ?? '',
      items:
          (json['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromJson(item))
              .toList() ??
          [],
      totalAmount: (json['totalAmount'] as num).toDouble(),
      status: json['status'] ?? 'pending',
      customerId: customer is String
          ? customer
          : customer?['_id']?.toString() ?? '',
      customerName: customer is Map<String, dynamic> ? customer['name'] : null,
      customerEmail: customer is Map<String, dynamic>
          ? customer['email']
          : null,
      tableNumber: json['tableNumber'],
      orderType: json['orderType'] ?? 'dine-in',
      orderDate: DateTime.parse(json['orderDate']),
      inventoryDeduction: json['inventoryDeduction'] != null
          ? InventoryDeduction.fromJson(json['inventoryDeduction'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'items': items.map((e) => e.toJson()).toList(),
      'totalAmount': totalAmount,
      'status': status,
      'customer': customerId,
      'tableNumber': tableNumber,
      'orderType': orderType,
      'orderDate': orderDate.toIso8601String(),
      'inventoryDeduction': inventoryDeduction?.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
