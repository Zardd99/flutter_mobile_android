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

final GetIt injector = GetIt.instance;

Future<void> setupInjector() async {
  // API Client
  injector.registerLazySingleton<ApiClient>(
    () => ApiClient(baseUrl: ApiConstants.baseUrl),
  );

  // Data Sources
  injector.registerLazySingleton<RemoteDataSource>(
    () => RemoteDataSource(apiClient: injector()),
  );

  injector.registerLazySingleton<LocalDataSource>(() => LocalDataSourceImpl());

  // Repositories
  injector.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: injector(),
      localDataSource: injector(),
    ),
  );

  injector.registerLazySingleton<MenuRepository>(
    () => MenuRepositoryImpl(injector<RemoteDataSource>()),
  );

  // Use Cases
  injector.registerLazySingleton<CreateMenuItemUseCase>(
    () => CreateMenuItemUseCase(injector<MenuRepository>()),
  );
  injector.registerLazySingleton<UpdateMenuItemUseCase>(
    () => UpdateMenuItemUseCase(injector<MenuRepository>()),
  );
  injector.registerLazySingleton<DeleteMenuItemUseCase>(
    () => DeleteMenuItemUseCase(injector<MenuRepository>()),
  );

  // Managers
  injector.registerLazySingleton<AuthManager>(
    () => AuthManager(authRepository: injector()),
  );

  injector.registerLazySingleton<MenuManager>(
    () => MenuManager(injector<MenuRepository>()),
  );

  // View Models
  injector.registerFactory<MenuViewModel>(
    () => MenuViewModel(injector<MenuManager>()),
  );
}

T get<T extends Object>() => injector.get<T>();
