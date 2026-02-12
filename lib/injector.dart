// *****************************************************************************
// Project: Restaurant Mobile App
// File: lib/injector.dart
// Description: Dependency injection configuration using GetIt.
//              Registers all dependencies for the application,
//              including API clients, data sources, repositories,
//              use cases, managers, and view models.
// *****************************************************************************

import 'package:get_it/get_it.dart';
import 'package:restaurant_mobile_app/core/network/api_client.dart';
import 'package:restaurant_mobile_app/core/constants/api_constants.dart';
import 'package:restaurant_mobile_app/data/data_sources/remote_data_source.dart';
import 'package:restaurant_mobile_app/data/data_sources/local_data_source.dart';
import 'package:restaurant_mobile_app/data/repositories_impl/auth_repository_impl.dart';
import 'package:restaurant_mobile_app/data/repositories_impl/menu_repository_impl.dart';
import 'package:restaurant_mobile_app/domain/repositories/auth_repository.dart';
import 'package:restaurant_mobile_app/domain/repositories/menu_repository.dart';
import 'package:restaurant_mobile_app/domain/use_cases/delete_menu_item_use_case.dart';
import 'package:restaurant_mobile_app/domain/use_cases/update_menu_item_use_case.dart';
import 'package:restaurant_mobile_app/domain/use_cases/create_menu_item_use_case.dart';
import 'package:restaurant_mobile_app/presentation/auth/view_models/auth_manager.dart';
import 'package:restaurant_mobile_app/presentation/menu/managers/menu_manager.dart';
import 'package:restaurant_mobile_app/presentation/menu/view_models/menu_view_model.dart';
import 'package:restaurant_mobile_app/data/repositories_impl/order_repository_impl.dart';
import 'package:restaurant_mobile_app/domain/repositories/order_repository.dart';
import 'package:restaurant_mobile_app/domain/use_cases/get_order_stats_use_case.dart';
import 'package:restaurant_mobile_app/domain/use_cases/get_orders_use_case.dart';
import 'package:restaurant_mobile_app/domain/use_cases/update_order_status_use_case.dart';
import 'package:restaurant_mobile_app/presentation/orders/managers/order_manager.dart';
import 'package:restaurant_mobile_app/domain/use_cases/create_order_use_case.dart';
import 'package:restaurant_mobile_app/domain/repositories/user_repository.dart';
import 'package:restaurant_mobile_app/data/repositories_impl/user_repository_impl.dart';
import 'package:restaurant_mobile_app/domain/use_cases/user/get_users_use_case.dart';
import 'package:restaurant_mobile_app/domain/use_cases/user/get_user_use_case.dart';
import 'package:restaurant_mobile_app/domain/use_cases/user/update_user_use_case.dart';
import 'package:restaurant_mobile_app/domain/use_cases/user/delete_user_use_case.dart';
import 'package:restaurant_mobile_app/presentation/users/managers/user_manager.dart';
import 'package:restaurant_mobile_app/presentation/users/view_models/users_view_model.dart';

/// Global GetIt instance used for dependency injection throughout the app.
final GetIt injector = GetIt.instance;

/// Configures and registers all dependencies with GetIt.
///
/// Call this function once during app initialisation (e.g., in `main()`).
/// All registrations are performed lazily where possible to improve startup time.
Future<void> setupInjector() async {
  // -------------------------------------------------------------------------
  // 1. CORE & NETWORK
  // -------------------------------------------------------------------------
  // ApiClient – low-level HTTP client.
  // Registered as a lazy singleton: same instance reused across the whole app.
  injector.registerLazySingleton<ApiClient>(
    () => ApiClient(baseUrl: ApiConstants.baseUrl),
  );

  // -------------------------------------------------------------------------
  // 2. DATA SOURCES
  // -------------------------------------------------------------------------
  // RemoteDataSource – abstracts API calls.
  // Depends on ApiClient.
  injector.registerLazySingleton<RemoteDataSource>(
    () => RemoteDataSource(apiClient: injector()),
  );

  // LocalDataSource – abstracts local storage (SecureStorage, SharedPreferences).
  // Registered as lazy singleton; its implementation is synchronous.
  injector.registerLazySingleton<LocalDataSource>(() => LocalDataSourceImpl());

  // -------------------------------------------------------------------------
  // 3. REPOSITORIES
  // -------------------------------------------------------------------------
  // Repositories implement the domain-layer interfaces and orchestrate
  // between remote/local data sources. All are lazy singletons.

  // AuthRepository – handles authentication and user session.
  injector.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: injector(),
      localDataSource: injector(),
    ),
  );

  // MenuRepository – manages menu items and categories.
  injector.registerLazySingleton<MenuRepository>(
    () => MenuRepositoryImpl(injector<RemoteDataSource>()),
  );

  // OrderRepository – manages orders and statistics.
  injector.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(injector<RemoteDataSource>()),
  );

  // UserRepository – manages user accounts (admin only).
  injector.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(injector<RemoteDataSource>()),
  );

  // -------------------------------------------------------------------------
  // 4. DOMAIN USE CASES
  // -------------------------------------------------------------------------
  // Use cases encapsulate single business logic operations.
  // They depend on repositories and are stateless; therefore registered as lazy singletons.

  // --- Menu Use Cases ---
  injector.registerLazySingleton<CreateMenuItemUseCase>(
    () => CreateMenuItemUseCase(injector<MenuRepository>()),
  );
  injector.registerLazySingleton<UpdateMenuItemUseCase>(
    () => UpdateMenuItemUseCase(injector<MenuRepository>()),
  );
  injector.registerLazySingleton<DeleteMenuItemUseCase>(
    () => DeleteMenuItemUseCase(injector<MenuRepository>()),
  );

  // --- Order Use Cases ---
  injector.registerLazySingleton<GetOrdersUseCase>(
    () => GetOrdersUseCase(injector<OrderRepository>()),
  );
  injector.registerLazySingleton<GetOrderStatsUseCase>(
    () => GetOrderStatsUseCase(injector<OrderRepository>()),
  );
  injector.registerLazySingleton<UpdateOrderStatusUseCase>(
    () => UpdateOrderStatusUseCase(injector<OrderRepository>()),
  );
  injector.registerLazySingleton<CreateOrderUseCase>(
    () => CreateOrderUseCase(injector<OrderRepository>()),
  );

  // --- User Management Use Cases ---
  injector.registerLazySingleton<GetUsersUseCase>(
    () => GetUsersUseCase(injector<UserRepository>()),
  );
  injector.registerLazySingleton<GetUserUseCase>(
    () => GetUserUseCase(injector<UserRepository>()),
  );
  injector.registerLazySingleton<UpdateUserUseCase>(
    () => UpdateUserUseCase(injector<UserRepository>()),
  );
  injector.registerLazySingleton<DeleteUserUseCase>(
    () => DeleteUserUseCase(injector<UserRepository>()),
  );

  // -------------------------------------------------------------------------
  // 5. MANAGERS (PRESENTATION LOGIC / CONTROLLERS)
  // -------------------------------------------------------------------------
  // Managers orchestrate use cases and hold transient state for a feature.
  // They are typically used by ViewModels or directly by UI components.
  // All are lazy singletons unless they require per‑screen state.

  // AuthManager – manages authentication state, token, and current user.
  injector.registerLazySingleton<AuthManager>(
    () => AuthManager(authRepository: injector()),
  );

  // MenuManager – provides menu operations to the UI.
  injector.registerLazySingleton<MenuManager>(
    () => MenuManager(injector<MenuRepository>()),
  );

  // OrderManager – provides order operations and statistics.
  // Depends on all order-related use cases.
  injector.registerLazySingleton<OrderManager>(
    () => OrderManager(
      getOrdersUseCase: injector<GetOrdersUseCase>(),
      getOrderStatsUseCase: injector<GetOrderStatsUseCase>(),
      updateOrderStatusUseCase: injector<UpdateOrderStatusUseCase>(),
      createOrderUseCase: injector<CreateOrderUseCase>(),
    ),
  );

  // UserManager – provides user management operations (admin).
  injector.registerLazySingleton<UserManager>(
    () => UserManager(
      getUsersUseCase: injector<GetUsersUseCase>(),
      getUserUseCase: injector<GetUserUseCase>(),
      updateUserUseCase: injector<UpdateUserUseCase>(),
      deleteUserUseCase: injector<DeleteUserUseCase>(),
    ),
  );

  // -------------------------------------------------------------------------
  // 6. VIEW MODELS
  // -------------------------------------------------------------------------
  // ViewModels expose state and commands to the UI and implement ChangeNotifier.
  // They are usually created per screen (factory) because they hold
  // screen‑specific state and may require runtime parameters.

  // MenuViewModel – no runtime parameters; simple factory.
  injector.registerFactory<MenuViewModel>(
    () => MenuViewModel(injector<MenuManager>()),
  );

  // UsersViewModel – requires an authentication token at creation time.
  // Uses `registerFactoryParam` to accept a String token.
  // Usage: injector.get<UsersViewModel>(param1: authToken)
  injector.registerFactoryParam<UsersViewModel, String, void>(
    (authToken, _) => UsersViewModel(
      userManager: injector<UserManager>(),
      authToken: authToken,
    ),
  );

  // -------------------------------------------------------------------------
  // NOTE: Additional ViewModels (OrdersViewModel, WaiterOrderViewModel, etc.)
  // should be registered here following the same patterns.
  // -------------------------------------------------------------------------
}

/// Convenience method to quickly retrieve a registered dependency.
///
/// Equivalent to `injector.get<T>()`. Reduces boilerplate.
///
/// Example:
///   final authManager = get<AuthManager>();
T get<T extends Object>() => injector.get<T>();
