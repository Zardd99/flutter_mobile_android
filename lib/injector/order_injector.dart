import 'package:restaurant_mobile_app/core/constants/api_constants.dart';
import 'package:restaurant_mobile_app/core/network/api_client.dart';
import 'package:restaurant_mobile_app/data/data_sources/remote_data_source.dart';
import 'package:restaurant_mobile_app/data/repositories_impl/order_repository_impl.dart';
import 'package:restaurant_mobile_app/domain/repositories/order_repository.dart';
import 'package:restaurant_mobile_app/domain/use_cases/get_order_stats_use_case.dart';
import 'package:restaurant_mobile_app/domain/use_cases/get_orders_use_case.dart';
import 'package:restaurant_mobile_app/domain/use_cases/update_order_status_use_case.dart';
import 'package:restaurant_mobile_app/presentation/orders/managers/order_manager.dart';

class OrderInjector {
  static ApiClient _provideApiClient() {
    return ApiClient(baseUrl: ApiConstants.baseUrl);
  }

  static RemoteDataSource _provideRemoteDataSource() {
    return RemoteDataSource(apiClient: _provideApiClient());
  }

  static OrderRepository provideOrderRepository() {
    return OrderRepositoryImpl(_provideRemoteDataSource());
  }

  static GetOrdersUseCase provideGetOrdersUseCase() {
    return GetOrdersUseCase(provideOrderRepository());
  }

  static GetOrderStatsUseCase provideGetOrderStatsUseCase() {
    return GetOrderStatsUseCase(provideOrderRepository());
  }

  static UpdateOrderStatusUseCase provideUpdateOrderStatusUseCase() {
    return UpdateOrderStatusUseCase(provideOrderRepository());
  }

  static OrderManager provideOrderManager() {
    return OrderManager(
      getOrdersUseCase: provideGetOrdersUseCase(),
      getOrderStatsUseCase: provideGetOrderStatsUseCase(),
      updateOrderStatusUseCase: provideUpdateOrderStatusUseCase(),
    );
  }
}
