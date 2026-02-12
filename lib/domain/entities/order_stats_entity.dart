import 'package:equatable/equatable.dart';

class OrderStatsEntity extends Equatable {
  final double dailyEarnings;
  final double weeklyEarnings;
  final double yearlyEarnings;
  final int todayOrderCount;
  final double avgOrderValue;
  final Map<String, int> ordersByStatus;
  final List<BestSellingDishEntity> bestSellingDishes;

  const OrderStatsEntity({
    required this.dailyEarnings,
    required this.weeklyEarnings,
    required this.yearlyEarnings,
    required this.todayOrderCount,
    required this.avgOrderValue,
    required this.ordersByStatus,
    required this.bestSellingDishes,
  });

  factory OrderStatsEntity.fromJson(Map<String, dynamic> json) {
    return OrderStatsEntity(
      dailyEarnings: (json['dailyEarnings'] as num?)?.toDouble() ?? 0.0,
      weeklyEarnings: (json['weeklyEarnings'] as num?)?.toDouble() ?? 0.0,
      yearlyEarnings: (json['yearlyEarnings'] as num?)?.toDouble() ?? 0.0,
      todayOrderCount: json['todayOrderCount'] ?? 0,
      avgOrderValue: (json['avgOrderValue'] as num?)?.toDouble() ?? 0.0,
      ordersByStatus: Map<String, int>.from(json['ordersByStatus'] ?? {}),
      bestSellingDishes:
          (json['bestSellingDishes'] as List<dynamic>?)
              ?.map((item) => BestSellingDishEntity.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dailyEarnings': dailyEarnings,
      'weeklyEarnings': weeklyEarnings,
      'yearlyEarnings': yearlyEarnings,
      'todayOrderCount': todayOrderCount,
      'avgOrderValue': avgOrderValue,
      'ordersByStatus': ordersByStatus,
      'bestSellingDishes': bestSellingDishes.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
    dailyEarnings,
    weeklyEarnings,
    yearlyEarnings,
    todayOrderCount,
    avgOrderValue,
    ordersByStatus,
    bestSellingDishes,
  ];
}

class BestSellingDishEntity extends Equatable {
  final String name;
  final int quantity;
  final double revenue;

  const BestSellingDishEntity({
    required this.name,
    required this.quantity,
    required this.revenue,
  });

  factory BestSellingDishEntity.fromJson(Map<String, dynamic> json) {
    return BestSellingDishEntity(
      name: json['name'] ?? 'Unknown Dish',
      quantity: json['quantity'] ?? 0,
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'quantity': quantity,
    'revenue': revenue,
  };

  @override
  List<Object?> get props => [name, quantity, revenue];
}
