import 'package:equatable/equatable.dart';

class OrderItemEntity extends Equatable {
  final String menuItemId;
  final String? menuItemName;
  final int quantity;
  final double price;
  final String? specialInstructions;
  final double? originalPrice;
  final double? discountAmount;
  final double? finalPrice;
  final String? appliedPromotionId;

  const OrderItemEntity({
    required this.menuItemId,
    this.menuItemName,
    required this.quantity,
    required this.price,
    this.specialInstructions,
    this.originalPrice,
    this.discountAmount,
    this.finalPrice,
    this.appliedPromotionId,
  });

  double get total => (finalPrice ?? price) * quantity;

  factory OrderItemEntity.fromJson(Map<String, dynamic> json) {
    final menuItem = json['menuItem'];

    return OrderItemEntity(
      menuItemId: menuItem is String
          ? menuItem
          : menuItem?['_id']?.toString() ?? '',
      menuItemName: menuItem is Map<String, dynamic> ? menuItem['name'] : null,
      quantity: json['quantity'] ?? 1,
      price: (json['price'] as num).toDouble(),
      specialInstructions: json['specialInstructions']?.toString(),
      originalPrice: (json['originalPrice'] as num?)?.toDouble(),
      discountAmount: (json['discountAmount'] as num?)?.toDouble(),
      finalPrice: (json['finalPrice'] as num?)?.toDouble(),
      appliedPromotionId: json['appliedPromotion']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'menuItem': menuItemId,
      'quantity': quantity,
      'price': price,
      'specialInstructions': specialInstructions,
      'originalPrice': originalPrice,
      'discountAmount': discountAmount,
      'finalPrice': finalPrice,
      'appliedPromotion': appliedPromotionId,
    };
  }

  @override
  List<Object?> get props => [
    menuItemId,
    quantity,
    price,
    specialInstructions,
    originalPrice,
    discountAmount,
    finalPrice,
    appliedPromotionId,
  ];
}

class OrderEntity extends Equatable {
  final String id;
  final List<OrderItemEntity> items;
  final double totalAmount;
  final double? totalDiscountAmount;
  final OrderStatus status;
  final String customerId;
  final String? customerName;
  final String? customerEmail;
  final int? tableNumber;
  final OrderType orderType;
  final DateTime orderDate;
  final InventoryDeductionEntity? inventoryDeduction;
  final DateTime createdAt;
  final DateTime updatedAt;

  const OrderEntity({
    required this.id,
    required this.items,
    required this.totalAmount,
    this.totalDiscountAmount,
    required this.status,
    required this.customerId,
    this.customerName,
    this.customerEmail,
    this.tableNumber,
    required this.orderType,
    required this.orderDate,
    this.inventoryDeduction,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderEntity.fromJson(Map<String, dynamic> json) {
    final customer = json['customer'];

    return OrderEntity(
      id: json['_id']?.toString() ?? '',
      items:
          (json['items'] as List<dynamic>?)
              ?.map((item) => OrderItemEntity.fromJson(item))
              .toList() ??
          [],
      totalAmount: (json['totalAmount'] as num).toDouble(),
      totalDiscountAmount: (json['totalDiscountAmount'] as num?)?.toDouble(),
      status: OrderStatus.fromString(json['status'] ?? 'pending'),
      customerId: customer is String
          ? customer
          : customer?['_id']?.toString() ?? '',
      customerName: customer is Map<String, dynamic> ? customer['name'] : null,
      customerEmail: customer is Map<String, dynamic>
          ? customer['email']
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

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'items': items.map((e) => e.toJson()).toList(),
      'totalAmount': totalAmount,
      'totalDiscountAmount': totalDiscountAmount,
      'status': status.value,
      'customer': customerId,
      'tableNumber': tableNumber,
      'orderType': orderType.value,
      'orderDate': orderDate.toIso8601String(),
      'inventoryDeduction': inventoryDeduction?.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    items,
    totalAmount,
    status,
    customerId,
    tableNumber,
    orderType,
    orderDate,
  ];
}

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  ready,
  served,
  cancelled;

  String get value => name;

  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.ready:
        return 'Ready to Serve';
      case OrderStatus.served:
        return 'Served';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  static OrderStatus fromString(String value) {
    return OrderStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => OrderStatus.pending,
    );
  }
}

enum OrderType {
  dineIn,
  takeaway,
  delivery;

  String get value {
    switch (this) {
      case OrderType.dineIn:
        return 'dine-in';
      case OrderType.takeaway:
        return 'takeaway';
      case OrderType.delivery:
        return 'delivery';
    }
  }

  String get displayName {
    switch (this) {
      case OrderType.dineIn:
        return 'Dine In';
      case OrderType.takeaway:
        return 'Takeaway';
      case OrderType.delivery:
        return 'Delivery';
    }
  }

  static OrderType fromString(String value) {
    switch (value) {
      case 'dine-in':
        return OrderType.dineIn;
      case 'takeaway':
        return OrderType.takeaway;
      case 'delivery':
        return OrderType.delivery;
      default:
        return OrderType.dineIn;
    }
  }
}

class InventoryDeductionEntity extends Equatable {
  final InventoryDeductionStatus status;
  final Map<String, dynamic>? data;
  final String? warning;
  final DateTime? timestamp;
  final DateTime? lastUpdated;

  const InventoryDeductionEntity({
    required this.status,
    this.data,
    this.warning,
    this.timestamp,
    this.lastUpdated,
  });

  factory InventoryDeductionEntity.fromJson(Map<String, dynamic> json) {
    return InventoryDeductionEntity(
      status: InventoryDeductionStatus.fromString(json['status'] ?? 'pending'),
      data: json['data'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['data'])
          : null,
      warning: json['warning']?.toString(),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : null,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status.value,
      'data': data,
      'warning': warning,
      'timestamp': timestamp?.toIso8601String(),
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [status, data, warning, timestamp, lastUpdated];
}

enum InventoryDeductionStatus {
  pending,
  completed,
  failed,
  skipped;

  String get value => name;

  static InventoryDeductionStatus fromString(String value) {
    return InventoryDeductionStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => InventoryDeductionStatus.pending,
    );
  }
}
