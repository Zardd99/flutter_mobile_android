class Order {
  final String id;
  final List<OrderItem> items;
  final double totalAmount;
  final String status;
  final String customerId;
  final String? customerName;
  final String? customerEmail;
  final int? tableNumber;
  final String orderType;
  final DateTime orderDate;
  final InventoryDeduction? inventoryDeduction;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Order({
    required this.id,
    required this.items,
    required this.totalAmount,
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

  factory Order.fromJson(Map<String, dynamic> json) {
    final customer = json['customer'];

    return Order(
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

  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
  bool get isPreparing => status == 'preparing';
  bool get isReady => status == 'ready';
  bool get isServed => status == 'served';
  bool get isCancelled => status == 'cancelled';

  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'preparing':
        return 'Preparing';
      case 'ready':
        return 'Ready to Serve';
      case 'served':
        return 'Served';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }
}

class OrderItem {
  final String menuItemId;
  final String? menuItemName;
  final int quantity;
  final String? specialInstructions;
  final double price;

  const OrderItem({
    required this.menuItemId,
    this.menuItemName,
    required this.quantity,
    this.specialInstructions,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final menuItem = json['menuItem'];

    return OrderItem(
      menuItemId: menuItem is String
          ? menuItem
          : menuItem?['_id']?.toString() ?? '',
      menuItemName: menuItem is Map<String, dynamic> ? menuItem['name'] : null,
      quantity: json['quantity'] ?? 1,
      specialInstructions: json['specialInstructions']?.toString(),
      price: (json['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'menuItem': menuItemId,
      'quantity': quantity,
      'specialInstructions': specialInstructions,
      'price': price,
    };
  }

  double get total => price * quantity;
}

class InventoryDeduction {
  final String status;
  final Map<String, dynamic>? data;
  final String? warning;
  final DateTime? timestamp;
  final DateTime? lastUpdated;

  const InventoryDeduction({
    required this.status,
    this.data,
    this.warning,
    this.timestamp,
    this.lastUpdated,
  });

  factory InventoryDeduction.fromJson(Map<String, dynamic> json) {
    return InventoryDeduction(
      status: json['status'] ?? 'pending',
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
      'status': status,
      'data': data,
      'warning': warning,
      'timestamp': timestamp?.toIso8601String(),
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  bool get isCompleted => status == 'completed';
  bool get isPending => status == 'pending';
  bool get isFailed => status == 'failed';
  bool get isSkipped => status == 'skipped';
}
