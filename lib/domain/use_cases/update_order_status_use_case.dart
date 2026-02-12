import 'package:restaurant_mobile_app/core/errors/result.dart';
import 'package:restaurant_mobile_app/domain/entities/order_entity.dart';
import 'package:restaurant_mobile_app/domain/repositories/order_repository.dart';

class UpdateOrderStatusUseCase {
  final OrderRepository _repository;

  UpdateOrderStatusUseCase(this._repository);

  Future<Result<OrderEntity>> execute({
    required String orderId,
    required String status,
    required String token,
  }) async {
    return await _repository.updateOrderStatus(
      orderId: orderId,
      status: OrderStatus.fromString(status),
      token: token,
    );
  }
}
