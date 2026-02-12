import 'package:restaurant_mobile_app/core/errors/result.dart';
import 'package:restaurant_mobile_app/domain/entities/order_stats_entity.dart';
import 'package:restaurant_mobile_app/domain/repositories/order_repository.dart';

class GetOrderStatsUseCase {
  final OrderRepository _repository;

  GetOrderStatsUseCase(this._repository);

  Future<Result<OrderStatsEntity>> execute({required String token}) async {
    return await _repository.getOrderStats(token: token);
  }
}
