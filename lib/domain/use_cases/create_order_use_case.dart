import 'package:restaurant_mobile_app/core/errors/result.dart';
import 'package:restaurant_mobile_app/domain/entities/order_entity.dart';
import 'package:restaurant_mobile_app/domain/repositories/order_repository.dart';

class CreateOrderUseCase {
  final OrderRepository _repository;
  CreateOrderUseCase(this._repository);

  Future<Result<OrderEntity>> execute({
    required Map<String, dynamic> orderData,
    required String token,
  }) {
    return _repository.createOrder(orderData: orderData, token: token);
  }
}
