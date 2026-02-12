import 'package:restaurant_mobile_app/core/errors/result.dart';
import 'package:restaurant_mobile_app/domain/entities/order_entity.dart';
import 'package:restaurant_mobile_app/domain/repositories/order_repository.dart';

class GetOrdersUseCase {
  final OrderRepository _repository;

  GetOrdersUseCase(this._repository);

  Future<Result<List<OrderEntity>>> execute({
    String? status,
    String? customerId,
    required String token,
  }) async {
    return await _repository.getAllOrders(
      status: status,
      customerId: customerId,
      token: token,
    );
  }
}
