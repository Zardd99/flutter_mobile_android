# Restaurant Mobile Application - Architecture & Design Documentation

**Version:** 1.0.0  
**Last Updated:** February 2026  
**Platform:** Flutter (iOS, Android, Web)  
**Language:** Dart 3.10.8+

---

## Executive Summary

The Restaurant Mobile Application is a comprehensive Flutter-based mobile management system designed for restaurant staff across multiple roles (admin, manager, chef, waiter, cashier). The application provides essential operational functionality including order management, menu administration, inventory tracking, supplier coordination, and customer reviews.

### Primary Value Proposition

- **Multi-role Support:** Tailored interfaces for different user roles with role-based access control
- **Real-time Operations:** Live order tracking, inventory updates, and staff coordination
- **Offline Capability:** Local data persistence allows basic functionality without connectivity
- **Scalable Architecture:** Clean separation of concerns enables feature expansion and maintenance
- **Performance Optimized:** Efficient data handling with minimal memory footprint

### Key Capabilities

| Capability              | Description                                                     |
| ----------------------- | --------------------------------------------------------------- |
| **Authentication**      | Secure login/registration with JWT token-based sessions         |
| **Order Management**    | Create, track, and update orders with multi-status workflow     |
| **Menu Administration** | Manage menu items, categories, dietary tags, and pricing        |
| **Inventory Tracking**  | Monitor ingredient stocks, low-stock alerts, reorder management |
| **Supplier Management** | Manage supplier information and ingredient sourcing             |
| **Reviews & Ratings**   | Customer feedback on menu items and service quality             |
| **User Management**     | Role-based user administration and profile management           |
| **Analytics Dashboard** | Order statistics and business metrics visualization             |

---

## Architecture & Design

### 1. Architectural Pattern: Clean Architecture (MVVM + Clean Layered)

The application follows **Clean Architecture** principles combined with **Model-View-ViewModel (MVVM)** pattern, ensuring:

- **Independence:** Business logic independent of UI frameworks
- **Testability:** Each layer can be tested in isolation
- **Maintainability:** Clear responsibilities and separation of concerns
- **Scalability:** Easy to extend with new features

#### Architectural Layers

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                        │
│  (Screens, Widgets, ViewModels, Managers, State Management) │
├─────────────────────────────────────────────────────────────┤
│                      DOMAIN LAYER                            │
│  (Entities, Repositories [Abstract], Use Cases, Validators) │
├─────────────────────────────────────────────────────────────┤
│                      DATA LAYER                              │
│  (Repositories [Implementation], Models, Data Sources)      │
├─────────────────────────────────────────────────────────────┤
│                      CORE LAYER                              │
│  (Network, Constants, Errors, Utilities, Common Widgets)    │
└─────────────────────────────────────────────────────────────┘
```

### 2. Data Flow Architecture

#### User Authentication Flow

```
LoginScreen (UI)
        ↓
LoginViewModel / AuthManager (State Management)
        ↓
AuthRepository (Domain - Abstract)
        ↓
AuthRepositoryImpl (Data Layer)
        ├→ RemoteDataSource → ApiClient → Network Request
        └→ LocalDataSource → SharedPreferences → Token Storage
        ↓
Result<User> (Success/Failure Wrapper)
        ↓
AppBar Navigation (Role-based routing)
```

#### Order Retrieval & Update Flow

```
OrdersScreen
        ↓
OrdersViewModel
        ↓
OrderManager (Business Logic Orchestrator)
        ├→ GetOrdersUseCase
        ├→ UpdateOrderStatusUseCase
        └→ GetOrderStatsUseCase
        ↓
OrderRepository (Abstract)
        ↓
OrderRepositoryImpl
        ├→ RemoteDataSource ← API Endpoints
        └→ LocalDataSource (Cache/Fallback)
        ↓
OrderModel ← OrderEntity (Domain)
        ↓
UI Update (Provider ChangeNotifier)
```

### 3. Design Patterns Implemented

#### A. Repository Pattern

Provides abstraction between data sources, allowing multiple implementations:

```dart
abstract class OrderRepository {
  Future<Result<List<OrderEntity>>> getAllOrders({
    String? status,
    String? customerId,
    required String token,
  });

  Future<Result<OrderEntity>> getOrderById(
    String id,
    String token,
  );

  Future<Result<OrderEntity>> updateOrderStatus(
    String id,
    String status,
    String token,
  );
}

// Implementation
class OrderRepositoryImpl implements OrderRepository {
  final RemoteDataSource _remoteDataSource;
  // Delegates calls to data sources
}
```

#### B. Use Case Pattern

Encapsulates single business operations with input validation:

```dart
class GetOrdersUseCase {
  final OrderRepository _repository;

  GetOrdersUseCase(this._repository);

  Future<Result<List<OrderEntity>>> execute({
    String? status,
    String? customerId,
    required String token,
  }) async {
    // Business logic validation
    return await _repository.getAllOrders(
      status: status,
      customerId: customerId,
      token: token,
    );
  }
}
```

#### C. Manager Pattern

Coordinates multiple use cases, providing simplified interface:

```dart
class OrderManager {
  final GetOrdersUseCase _getOrdersUseCase;
  final UpdateOrderStatusUseCase _updateOrderStatusUseCase;
  final GetOrderStatsUseCase _getOrderStatsUseCase;

  // Provides single interface for order operations
  Future<Result<List<OrderEntity>>> getOrders({
    required String token,
    String? status,
  }) async {
    return await _getOrdersUseCase.execute(token: token, status: status);
  }
}
```

#### D. Dependency Injection (Service Locator)

Uses `get_it` for centralized dependency registration:

```dart
final injector = GetIt.instance;

Future<void> setupInjector() async {
  // Register singletons (one instance app-wide)
  injector.registerLazySingleton<ApiClient>(
    () => ApiClient(baseUrl: ApiConstants.baseUrl),
  );

  // Register data sources
  injector.registerLazySingleton<RemoteDataSource>(
    () => RemoteDataSource(apiClient: injector()),
  );

  // Register repositories
  injector.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(injector<RemoteDataSource>()),
  );

  // Register use cases
  injector.registerLazySingleton<GetOrdersUseCase>(
    () => GetOrdersUseCase(injector<OrderRepository>()),
  );

  // Register managers
  injector.registerLazySingleton<OrderManager>(
    () => OrderManager(
      getOrdersUseCase: injector<GetOrdersUseCase>(),
      updateOrderStatusUseCase: injector<UpdateOrderStatusUseCase>(),
      getOrderStatsUseCase: injector<GetOrderStatsUseCase>(),
      createOrderUseCase: injector<CreateOrderUseCase>(),
    ),
  );
}
```

#### E. State Management (Provider Pattern)

Manages UI state with `ChangeNotifier` and `Provider`:

```dart
class MenuViewModel extends ChangeNotifier {
  final MenuManager _menuManager;

  List<MenuItem> _menuItems = [];
  bool _isLoading = false;
  String? _error;

  // Getters for reactive state
  List<MenuItem> get menuItems => _menuItems;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Notification triggers UI rebuild
  Future<void> loadMenuItems() async {
    _isLoading = true;
    notifyListeners();

    final result = await _menuManager.getAllMenuItems();
    result.fold(
      onSuccess: (items) {
        _menuItems = items;
        _error = null;
      },
      onFailure: (failure) {
        _error = failure.message;
      },
    );

    _isLoading = false;
    notifyListeners();
  }
}
```

#### F. Result Type (Sealed Class Pattern)

Type-safe error handling without exceptions:

```dart
sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is ResultFailure<T>;

  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(Failure failure) onFailure,
  }) {
    return switch (this) {
      Success<T>(:final value) => onSuccess(value),
      ResultFailure<T>(:final failure) => onFailure(failure),
    };
  }

  Result<R> map<R>(R Function(T value) transform) {
    return switch (this) {
      Success<T>(:final value) => Success(transform(value)),
      ResultFailure<T>(:final failure) => ResultFailure(failure),
    };
  }
}

class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);
}

class ResultFailure<T> extends Result<T> {
  final Failure failure;
  const ResultFailure(this.failure);
}
```

---

## Module Breakdown

### 1. Core Module (`lib/core/`)

**Responsibility:** Shared utilities and infrastructure

#### A. Network (`core/network/`)

**Component:** `ApiClient`

Centralized HTTP communication handler with:

- Request/response serialization
- Error handling and timeouts
- Authentication header injection
- Timeout management (15 seconds)

**Key Methods:**

```dart
class ApiClient {
  final String baseUrl;
  final Map<String, String> defaultHeaders;

  Future<Result<Map<String, dynamic>>> get(
    String endpoint, {
    Map<String, String>? queryParams,
    String? authToken,
  })

  Future<Result<Map<String, dynamic>>> post(
    String endpoint,
    Map<String, dynamic> body, {
    String? authToken,
  })

  Future<Result<Map<String, dynamic>>> put(
    String endpoint,
    Map<String, dynamic> body, {
    String? authToken,
  })

  Future<Result<Map<String, dynamic>>> delete(
    String endpoint, {
    String? authToken,
  })

  Future<Result<List<dynamic>>> getList(
    String endpoint, {
    Map<String, String>? queryParams,
    String? authToken,
  })
}
```

#### B. Error Handling (`core/errors/`)

**Components:** `Failure`, `Result`

Implements exception-free error handling through sealed classes:

```dart
abstract class Failure {
  final String message;

  const Failure(this.message);

  factory Failure.network(String message) = NetworkFailure;
  factory Failure.server(String message) = ServerFailure;
  factory Failure.authentication(String message) = AuthenticationFailure;
  factory Failure.permission(String message) = PermissionFailure;
  factory Failure.validation(String message) = ValidationFailure;
}

// Specific failures
class NetworkFailure extends Failure { ... }
class ServerFailure extends Failure { ... }
class AuthenticationFailure extends Failure { ... }
class PermissionFailure extends Failure { ... }
class ValidationFailure extends Failure { ... }
class GenericFailure extends Failure { ... }
```

#### C. Constants (`core/constants/`)

**Component:** `ApiConstants`, `AppConstants`

Centralized configuration:

```dart
abstract class ApiConstants {
  // Base configuration
  static const String baseUrl = 'https://nontenurial-fawn-socketless.ngrok-free.dev/api';
  static const int connectTimeout = 15000;
  static const int receiveTimeout = 15000;

  // API Endpoints
  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';
  static const String menu = '/menu';
  static const String orders = '/orders';
  static const String inventory = '/inventory';
  static const String suppliers = '/supplier';
  static const String reviews = '/reviews';
  static const String users = '/users';
}

abstract class AppConstants {
  static const String appName = 'Restaurant Manager';
  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const int defaultPageSize = 20;

  static const List<String> orderStatuses = [
    'pending', 'confirmed', 'preparing', 'ready', 'served', 'cancelled'
  ];

  static const List<String> userRoles = [
    'admin', 'manager', 'chef', 'waiter', 'cashier', 'customer'
  ];
}
```

#### D. Utilities (`core/utils/`)

Helper functions for:

- Date/time formatting
- String validation and transformation
- Number formatting and calculations

#### E. Widgets (`core/widgets/`)

Reusable UI components:

- `LoadingIndicator` - Centralized loading state UI
- `ErrorMessage` - Consistent error display
- `EmptyState` - Standard empty list UI
- `RoleBasedWidget` - Role-conditional rendering

---

### 2. Domain Layer (`lib/domain/`)

**Responsibility:** Core business logic and abstractions

#### A. Entities

**Definition:** Pure business objects, framework-agnostic

```dart
// OrderEntity - Business model
class OrderEntity extends Equatable {
  final String id;
  final List<OrderItemEntity> items;
  final double totalAmount;
  final OrderStatus status;
  final String customerId;
  final String? customerName;
  final String tableNumber;
  final OrderType orderType;
  final DateTime orderDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const OrderEntity({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.customerId,
    this.customerName,
    required this.tableNumber,
    required this.orderType,
    required this.orderDate,
    required this.createdAt,
    required this.updatedAt,
  });

  // Computed properties
  double get subtotal => items.fold(0, (sum, item) => sum + item.total);
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);
}

// OrderItemEntity
class OrderItemEntity extends Equatable {
  final String menuItemId;
  final String? menuItemName;
  final int quantity;
  final double price;
  final String? specialInstructions;
  final double? discountAmount;
  final double? finalPrice;

  const OrderItemEntity({
    required this.menuItemId,
    this.menuItemName,
    required this.quantity,
    required this.price,
    this.specialInstructions,
    this.discountAmount,
    this.finalPrice,
  });

  double get total => (finalPrice ?? price) * quantity;
}

// Value Objects
enum OrderStatus {
  pending('pending'),
  confirmed('confirmed'),
  preparing('preparing'),
  ready('ready'),
  served('served'),
  cancelled('cancelled');

  final String value;
  const OrderStatus(this.value);

  static OrderStatus fromString(String status) {
    return OrderStatus.values.firstWhere(
      (s) => s.value == status.toLowerCase(),
      orElse: () => OrderStatus.pending,
    );
  }
}

enum OrderType {
  dineIn('dine-in'),
  takeaway('takeaway'),
  delivery('delivery');

  final String value;
  const OrderType(this.value);
}
```

#### B. Repositories (Abstract)

**Pattern:** Interface for data access abstraction

```dart
abstract class AuthRepository {
  Future<Result<User>> login(AuthCredentials credentials);
  Future<Result<User>> register(RegisterData data);
  Future<Result<User>> getCurrentUser(String token);
  Future<Result<User>> updateProfile(
    Map<String, dynamic> updates,
    String token,
  );
  Future<Result<void>> changePassword(ChangePasswordData data, String token);
  Future<Result<void>> logout();
  Future<Result<String>> getStoredToken();
  Future<Result<void>> saveToken(String token);
  Future<Result<void>> clearToken();
}

abstract class OrderRepository {
  Future<Result<List<OrderEntity>>> getAllOrders({
    String? status,
    String? customerId,
    required String token,
  });
  Future<Result<OrderEntity>> getOrderById(String id, String token);
  Future<Result<OrderEntity>> createOrder(
    Map<String, dynamic> orderData,
    String token,
  );
  Future<Result<OrderEntity>> updateOrderStatus(
    String id,
    String status,
    String token,
  );
  Future<Result<OrderStatsEntity>> getOrderStats(String token);
}

abstract class MenuRepository {
  Future<Result<List<MenuItem>>> getAllMenuItems({
    String? category,
    String? dietary,
    String? search,
    bool? available,
    bool? chefSpecial,
    String? token,
  });
  Future<Result<MenuItem>> getMenuItemById(String id, String? token);
  Future<Result<MenuItem>> createMenuItem(
    Map<String, dynamic> data,
    String token,
  );
  Future<Result<MenuItem>> updateMenuItem(
    String id,
    Map<String, dynamic> data,
    String token,
  );
  Future<Result<void>> deleteMenuItem(String id, String token);
}
```

#### C. Use Cases

**Pattern:** Single responsibility, handles one business operation

```dart
class GetOrdersUseCase {
  final OrderRepository _repository;

  GetOrdersUseCase(this._repository);

  Future<Result<List<OrderEntity>>> execute({
    String? status,
    String? customerId,
    required String token,
  }) async {
    // Validation
    if (token.isEmpty) {
      return ResultFailure(AuthenticationFailure('No authentication token'));
    }

    // Delegate to repository
    return await _repository.getAllOrders(
      status: status,
      customerId: customerId,
      token: token,
    );
  }
}

class UpdateOrderStatusUseCase {
  final OrderRepository _repository;

  UpdateOrderStatusUseCase(this._repository);

  Future<Result<OrderEntity>> execute({
    required String orderId,
    required String status,
    required String token,
  }) async {
    // Input validation
    if (orderId.isEmpty || status.isEmpty || token.isEmpty) {
      return ResultFailure(ValidationFailure('Missing required fields'));
    }

    // Validate order status
    final validStatuses = ['pending', 'confirmed', 'preparing', 'ready', 'served', 'cancelled'];
    if (!validStatuses.contains(status.toLowerCase())) {
      return ResultFailure(ValidationFailure('Invalid order status: $status'));
    }

    return await _repository.updateOrderStatus(orderId, status, token);
  }
}

class CreateMenuItemUseCase {
  final MenuRepository _repository;

  CreateMenuItemUseCase(this._repository);

  Future<Result<MenuItem>> execute({
    required String name,
    required String description,
    required double price,
    required String categoryId,
    required List<String> dietaryTags,
    required int preparationTime,
    bool chefSpecial = false,
    bool availability = true,
  }) async {
    // Business logic validation
    if (name.isEmpty || description.isEmpty) {
      return ResultFailure(ValidationFailure('Name and description required'));
    }

    if (price <= 0) {
      return ResultFailure(ValidationFailure('Price must be greater than 0'));
    }

    if (preparationTime <= 0 || preparationTime > 240) {
      return ResultFailure(ValidationFailure('Preparation time must be 1-240 minutes'));
    }

    final data = {
      'name': name,
      'description': description,
      'price': price,
      'category': categoryId,
      'dietaryTags': dietaryTags,
      'preparationTime': preparationTime,
      'chefSpecial': chefSpecial,
      'availability': availability,
    };

    return await _repository.createMenuItem(data, '');
  }
}
```

#### D. Validators

**Purpose:** Domain-specific validation logic

```dart
class MenuItemValidator {
  static Result<void> validateMenuItemData({
    required String name,
    required String description,
    required double price,
    required String categoryId,
    required int preparationTime,
  }) {
    if (name.trim().isEmpty) {
      return ResultFailure(ValidationFailure('Menu item name cannot be empty'));
    }

    if (name.length > 100) {
      return ResultFailure(ValidationFailure('Menu item name too long (max 100 characters)'));
    }

    if (description.trim().isEmpty) {
      return ResultFailure(ValidationFailure('Description cannot be empty'));
    }

    if (price <= 0 || price > 10000) {
      return ResultFailure(ValidationFailure('Price must be between 0.01 and 10000'));
    }

    if (categoryId.isEmpty) {
      return ResultFailure(ValidationFailure('Category is required'));
    }

    if (preparationTime < 1 || preparationTime > 240) {
      return ResultFailure(ValidationFailure('Preparation time must be 1-240 minutes'));
    }

    return Success(null);
  }
}
```

---

### 3. Data Layer (`lib/data/`)

**Responsibility:** Concrete data source implementations

#### A. Data Sources

**Remote Data Source:**

```dart
class RemoteDataSource {
  final ApiClient apiClient;

  RemoteDataSource({required this.apiClient});

  // Authentication
  Future<Result<Map<String, dynamic>>> login(
    Map<String, dynamic> credentials,
  ) async {
    return apiClient.post(ApiConstants.authLogin, credentials);
  }

  // Menu Operations
  Future<Result<List<dynamic>>> getAllMenuItems({
    String? category,
    String? dietary,
    String? search,
    bool? available,
    bool? chefSpecial,
    String? token,
  }) async {
    final queryParams = <String, String>{};
    if (category != null) queryParams['category'] = category;
    if (dietary != null) queryParams['dietary'] = dietary;
    if (search != null) queryParams['search'] = search;
    if (available != null) queryParams['available'] = available.toString();
    if (chefSpecial != null) queryParams['chefSpecial'] = chefSpecial.toString();

    return apiClient.getList(
      ApiConstants.menu,
      queryParams: queryParams,
      authToken: token,
    );
  }

  // Order Operations
  Future<Result<Map<String, dynamic>>> getOrders(
    String token, {
    String? status,
  }) async {
    final params = <String, String>{};
    if (status != null) params['status'] = status;

    return apiClient.get(
      ApiConstants.orders,
      queryParams: params,
      authToken: token,
    );
  }

  Future<Result<Map<String, dynamic>>> createOrder(
    Map<String, dynamic> orderData,
    String token,
  ) async {
    return apiClient.post(
      ApiConstants.orders,
      orderData,
      authToken: token,
    );
  }

  Future<Result<Map<String, dynamic>>> updateOrderStatus(
    String orderId,
    String status,
    String token,
  ) async {
    return apiClient.put(
      '${ApiConstants.orders}/$orderId',
      {'status': status},
      authToken: token,
    );
  }
}
```

**Local Data Source:**

```dart
abstract class LocalDataSource {
  Future<void> saveAuthToken(String token);
  Future<String?> getAuthToken();
  Future<void> saveUserData(Map<String, dynamic> userData);
  Future<Map<String, dynamic>?> getUserData();
  Future<void> clearAuthData();
}

class LocalDataSourceImpl implements LocalDataSource {
  static const String _authTokenKey = 'auth_token';
  static const String _userDataKey = 'user_data';

  @override
  Future<void> saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authTokenKey, token);
  }

  @override
  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_authTokenKey);
  }

  @override
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userDataKey, jsonEncode(userData));
  }

  @override
  Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString(_userDataKey);

    if (userDataString == null) return null;

    try {
      return jsonDecode(userDataString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authTokenKey);
    await prefs.remove(_userDataKey);
  }
}
```

#### B. Models (Data Transfer Objects)

**Purpose:** Map API responses to domain entities

```dart
class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.items,
    required super.totalAmount,
    required super.status,
    required super.customerId,
    super.customerName,
    super.tableNumber,
    required super.orderType,
    required super.orderDate,
    required super.createdAt,
    required super.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['_id']?.toString() ?? '',
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => OrderItemEntity.fromJson(item))
          .toList() ?? [],
      totalAmount: (json['totalAmount'] as num).toDouble(),
      status: OrderStatus.fromString(json['status'] ?? 'pending'),
      customerId: json['customer'] is String
          ? json['customer']
          : json['customer']?['_id']?.toString() ?? '',
      customerName: json['customerName']?.toString(),
      tableNumber: json['tableNumber']?.toString() ?? '',
      orderType: OrderType.fromString(json['orderType'] ?? 'dine-in'),
      orderDate: DateTime.parse(json['orderDate'] ?? DateTime.now()),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'status': status.value,
      'customer': customerId,
      'customerName': customerName,
      'tableNumber': tableNumber,
      'orderType': orderType.value,
      'orderDate': orderDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class MenuItemModel extends MenuItem {
  const MenuItemModel({
    required super.id,
    required super.name,
    required super.description,
    required super.price,
    required super.categoryId,
    super.categoryName,
    required super.dietaryTags,
    required super.availability,
    required super.preparationTime,
    required super.chefSpecial,
    super.imageUrl,
    required super.createdAt,
    required super.updatedAt,
  });

  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    final category = json['category'];
    return MenuItemModel(
      id: json['_id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      categoryId: category is String ? category : category?['_id']?.toString() ?? '',
      categoryName: category is Map<String, dynamic> ? category['name'] : null,
      dietaryTags: List<String>.from(json['dietaryTags'] ?? []),
      availability: json['availability'] ?? true,
      preparationTime: json['preparationTime'] ?? 15,
      chefSpecial: json['chefSpecial'] ?? false,
      imageUrl: json['imageUrl']?.toString() ?? json['image']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) '_id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': categoryId,
      'dietaryTags': dietaryTags,
      'availability': availability,
      'preparationTime': preparationTime,
      'chefSpecial': chefSpecial,
      if (imageUrl != null) 'imageUrl': imageUrl,
    };
  }
}
```

#### C. Repository Implementations

```dart
class AuthRepositoryImpl implements AuthRepository {
  final RemoteDataSource _remoteDataSource;
  final LocalDataSource _localDataSource;

  AuthRepositoryImpl({
    required RemoteDataSource remoteDataSource,
    required LocalDataSource localDataSource,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource;

  @override
  Future<Result<User>> login(AuthCredentials credentials) async {
    final result = await _remoteDataSource.login({
      'email': credentials.email,
      'password': credentials.password,
    });

    return result.fold(
      onSuccess: (data) async {
        final token = data['token'] as String;
        final userData = data['user'] as Map<String, dynamic>;

        // Persist token and user data locally
        await _localDataSource.saveAuthToken(token);
        await _localDataSource.saveUserData(userData);

        return Success(User.fromJson(userData));
      },
      onFailure: (failure) => ResultFailure(failure),
    );
  }

  @override
  Future<Result<void>> logout() async {
    await _localDataSource.clearAuthData();
    return Success(null);
  }

  @override
  Future<Result<String>> getStoredToken() async {
    final token = await _localDataSource.getAuthToken();
    if (token != null && token.isNotEmpty) {
      return Success(token);
    }
    return ResultFailure(AuthenticationFailure('No stored token'));
  }
}

class OrderRepositoryImpl implements OrderRepository {
  final RemoteDataSource _remoteDataSource;

  OrderRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<List<OrderEntity>>> getAllOrders({
    String? status,
    String? customerId,
    required String token,
  }) async {
    if (token.isEmpty) {
      return ResultFailure(AuthenticationFailure('No authentication token'));
    }

    final result = await _remoteDataSource.getOrders(token, status: status);

    return result.fold(
      onSuccess: (data) {
        final orders = (data as List<dynamic>)
            .map((item) => OrderModel.fromJson(item))
            .toList();
        return Success(orders);
      },
      onFailure: (failure) => ResultFailure(failure),
    );
  }

  @override
  Future<Result<OrderEntity>> createOrder(
    Map<String, dynamic> orderData,
    String token,
  ) async {
    final result = await _remoteDataSource.createOrder(orderData, token);

    return result.fold(
      onSuccess: (data) => Success(OrderModel.fromJson(data)),
      onFailure: (failure) => ResultFailure(failure),
    );
  }

  @override
  Future<Result<OrderEntity>> updateOrderStatus(
    String id,
    String status,
    String token,
  ) async {
    final result = await _remoteDataSource.updateOrderStatus(id, status, token);

    return result.fold(
      onSuccess: (data) => Success(OrderModel.fromJson(data)),
      onFailure: (failure) => ResultFailure(failure),
    );
  }
}
```

---

### 4. Presentation Layer (`lib/presentation/`)

**Responsibility:** User interface and state management

#### A. Authentication Module (`presentation/auth/`)

**Structure:**

```
auth/
├── screens/
│   ├── login_screen.dart
│   └── register_screen.dart
├── view_models/
│   ├── auth_manager.dart
│   └── login_view_model.dart
└── widgets/
    ├── email_input_field.dart
    └── password_input_field.dart
```

**AuthManager (Global State Manager):**

```dart
class AuthManager extends ChangeNotifier {
  final AuthRepository _authRepository;

  User? _currentUser;
  String? _token;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _error;
  bool _isInitialized = false;

  // Public getters
  User? get currentUser => _currentUser;
  String? get token => _token;
  bool get isAuthenticated => _isAuthenticated;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    final tokenResult = await _authRepository.getStoredToken();

    tokenResult.fold(
      onSuccess: (token) async {
        _token = token;
        if (token.isNotEmpty) {
          // Verify token by fetching current user
          final userResult = await _authRepository.getCurrentUser(token);
          userResult.fold(
            onSuccess: (user) {
              _currentUser = user;
              _isAuthenticated = true;
              _error = null;
            },
            onFailure: (failure) {
              _currentUser = null;
              _isAuthenticated = false;
              _error = failure.message;
            },
          );
        }
      },
      onFailure: (failure) {
        _isAuthenticated = false;
        _error = failure.message;
      },
    );

    _isLoading = false;
    _isInitialized = true;
    notifyListeners();
  }

  Future<Result<User>> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final credentials = AuthCredentials(email: email, password: password);
    final result = await _authRepository.login(credentials);

    result.fold(
      onSuccess: (user) async {
        _currentUser = user;
        _isAuthenticated = true;
        _error = null;

        // Retrieve and cache token
        final tokenResult = await _authRepository.getStoredToken();
        tokenResult.fold(
          onSuccess: (token) { _token = token; },
          onFailure: (_) {},
        );
      },
      onFailure: (failure) {
        _currentUser = null;
        _isAuthenticated = false;
        _error = failure.message;
      },
    );

    _isLoading = false;
    notifyListeners();
    return result;
  }

  Future<Result<void>> logout() async {
    _isLoading = true;
    notifyListeners();

    final result = await _authRepository.logout();

    result.fold(
      onSuccess: (_) {
        _currentUser = null;
        _token = null;
        _isAuthenticated = false;
        _error = null;
      },
      onFailure: (failure) {
        _error = failure.message;
      },
    );

    _isLoading = false;
    notifyListeners();
    return result;
  }
}
```

#### B. Orders Module (`presentation/orders/`)

**Structure:**

```
orders/
├── screens/
│   ├── orders_screen.dart
│   ├── order_detail_screen.dart
│   ├── waiter_order_screen.dart
│   └── kds_screen.dart
├── view_models/
│   ├── orders_view_model.dart
│   └── waiter_order_view_model.dart
├── managers/
│   └── order_manager.dart
└── widgets/
    ├── order_card.dart
    ├── order_status_badge.dart
    └── order_item_list.dart
```

**OrderManager (Business Logic Orchestrator):**

```dart
class OrderManager {
  final GetOrdersUseCase _getOrdersUseCase;
  final GetOrderStatsUseCase _getOrderStatsUseCase;
  final UpdateOrderStatusUseCase _updateOrderStatusUseCase;
  final CreateOrderUseCase _createOrderUseCase;

  OrderManager({
    required GetOrdersUseCase getOrdersUseCase,
    required GetOrderStatsUseCase getOrderStatsUseCase,
    required UpdateOrderStatusUseCase updateOrderStatusUseCase,
    required CreateOrderUseCase createOrderUseCase,
  }) : _getOrdersUseCase = getOrdersUseCase,
       _getOrderStatsUseCase = getOrderStatsUseCase,
       _updateOrderStatusUseCase = updateOrderStatusUseCase,
       _createOrderUseCase = createOrderUseCase;

  Future<Result<List<OrderEntity>>> getOrders({
    required String token,
    String? status,
  }) async {
    return await _getOrdersUseCase.execute(token: token, status: status);
  }

  Future<Result<OrderEntity>> createOrder({
    required Map<String, dynamic> orderData,
    required String token,
  }) {
    return _createOrderUseCase.execute(orderData: orderData, token: token);
  }

  Future<Result<OrderStatsEntity>> getOrderStats({
    required String token,
  }) async {
    return await _getOrderStatsUseCase.execute(token: token);
  }

  Future<Result<OrderEntity>> updateOrderStatus({
    required String orderId,
    required String status,
    required String token,
  }) async {
    return await _updateOrderStatusUseCase.execute(
      orderId: orderId,
      status: status,
      token: token,
    );
  }
}
```

**OrdersViewModel (UI State):**

```dart
class OrdersViewModel extends ChangeNotifier {
  final OrderManager _orderManager;
  final AuthManager _authManager;

  List<OrderEntity> _orders = [];
  OrderStatsEntity? _orderStats;
  bool _isLoading = false;
  String? _error;
  String? _statusFilter;
  bool _isRefreshing = false;

  // Public getters
  List<OrderEntity> get orders => _orders;
  OrderStatsEntity? get orderStats => _orderStats;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String? get error => _error;

  OrdersViewModel({
    required OrderManager orderManager,
    required AuthManager authManager,
  }) : _orderManager = orderManager,
       _authManager = authManager;

  Future<void> loadOrders({String? statusFilter}) async {
    if (_authManager.token == null || _authManager.token!.isEmpty) {
      _error = 'Not authenticated';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _statusFilter = statusFilter;
    _error = null;
    notifyListeners();

    final result = await _orderManager.getOrders(
      token: _authManager.token!,
      status: statusFilter,
    );

    result.fold(
      onSuccess: (orders) {
        _orders = orders;
        _error = null;
      },
      onFailure: (failure) {
        _error = failure.message;
        _orders = [];
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshOrders() async {
    _isRefreshing = true;
    notifyListeners();

    await loadOrders(statusFilter: _statusFilter);

    _isRefreshing = false;
    notifyListeners();
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    if (_authManager.token == null) {
      _error = 'Not authenticated';
      notifyListeners();
      return;
    }

    final result = await _orderManager.updateOrderStatus(
      orderId: orderId,
      status: newStatus,
      token: _authManager.token!,
    );

    result.fold(
      onSuccess: (updatedOrder) {
        final index = _orders.indexWhere((o) => o.id == orderId);
        if (index != -1) {
          _orders[index] = updatedOrder;
        }
        _error = null;
      },
      onFailure: (failure) {
        _error = 'Failed to update order: ${failure.message}';
      },
    );

    notifyListeners();
  }

  Future<void> loadOrderStats() async {
    if (_authManager.token == null) {
      return;
    }

    final result = await _orderManager.getOrderStats(
      token: _authManager.token!,
    );

    result.fold(
      onSuccess: (stats) {
        _orderStats = stats;
      },
      onFailure: (failure) {
        _error = 'Failed to load stats: ${failure.message}';
      },
    );

    notifyListeners();
  }
}
```

#### C. Menu Module (`presentation/menu/`)

**MenuViewModel:**

```dart
class MenuViewModel extends ChangeNotifier {
  final MenuManager _menuManager;

  List<MenuItem> _menuItems = [];
  bool _isLoading = false;
  String? _error;
  String? _categoryFilter;
  String? _searchQuery;
  bool _availableOnly = false;
  bool _chefSpecialOnly = false;

  List<MenuItem> get menuItems => _menuItems;
  bool get isLoading => _isLoading;
  String? get error => _error;

  MenuViewModel(this._menuManager);

  Future<void> loadMenuItems() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _menuManager.getAllMenuItems();

    result.fold(
      onSuccess: (items) {
        _menuItems = items;
        _error = null;
      },
      onFailure: (failure) {
        _error = failure.message;
        _menuItems = [];
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<Result<MenuItem>> createMenuItem({
    required String name,
    required String description,
    required double price,
    required String categoryId,
    required List<String> dietaryTags,
    required int preparationTime,
  }) async {
    _isLoading = true;
    notifyListeners();

    final result = await _menuManager.createMenuItem(
      name: name,
      description: description,
      price: price,
      categoryId: categoryId,
      dietaryTags: dietaryTags,
      preparationTime: preparationTime,
    );

    result.fold(
      onSuccess: (newItem) {
        _menuItems.add(newItem);
      },
      onFailure: (failure) {
        _error = failure.message;
      },
    );

    _isLoading = false;
    notifyListeners();

    return result;
  }

  Future<Result<MenuItem>> updateMenuItem(
    String id,
    Map<String, dynamic> updates,
  ) async {
    final result = await _menuManager.updateMenuItem(id, updates);

    result.fold(
      onSuccess: (updated) {
        final index = _menuItems.indexWhere((m) => m.id == id);
        if (index != -1) {
          _menuItems[index] = updated;
        }
      },
      onFailure: (failure) {
        _error = failure.message;
      },
    );

    notifyListeners();
    return result;
  }

  Future<Result<void>> deleteMenuItem(String id) async {
    final result = await _menuManager.deleteMenuItem(id);

    result.fold(
      onSuccess: (_) {
        _menuItems.removeWhere((m) => m.id == id);
      },
      onFailure: (failure) {
        _error = failure.message;
      },
    );

    notifyListeners();
    return result;
  }

  void applyFilters({
    String? category,
    String? search,
    bool? availableOnly,
    bool? chefSpecialOnly,
  }) {
    _categoryFilter = category;
    _searchQuery = search;
    _availableOnly = availableOnly ?? false;
    _chefSpecialOnly = chefSpecialOnly ?? false;
    notifyListeners();
  }

  List<MenuItem> get filteredMenuItems {
    return _menuItems.where((item) {
      if (_categoryFilter != null && item.categoryId != _categoryFilter) {
        return false;
      }
      if (_searchQuery != null && !item.name.toLowerCase().contains(_searchQuery!.toLowerCase())) {
        return false;
      }
      if (_availableOnly && !item.availability) {
        return false;
      }
      if (_chefSpecialOnly && !item.chefSpecial) {
        return false;
      }
      return true;
    }).toList();
  }
}
```

---

## Implementation Logic: Critical Business Operations

### 1. Authentication Flow

**Login Process:**

```
1. User Input Validation
   - Email format check
   - Password minimum length check

2. API Communication
   - POST /auth/login with credentials
   - Receive JWT token + user data

3. Local Data Persistence
   - Save token to SharedPreferences
   - Cache user data locally

4. State Management Update
   - Set _isAuthenticated = true
   - Store user object
   - Clear error messages

5. Navigation
   - Route based on user role
   - Admin/Manager → Dashboard
   - Chef → KDS Screen
   - Waiter → Orders Screen

6. Error Handling
   - Network errors → "Connection failed"
   - Invalid credentials → "Email or password incorrect"
   - Server errors → Display error message
```

**Token Refresh Logic:**

```dart
// On app initialization
Future<void> initialize() async {
  final tokenResult = await _authRepository.getStoredToken();

  if (tokenResult.isSuccess) {
    final token = tokenResult.valueOrNull;

    // Verify token validity
    final userResult = await _authRepository.getCurrentUser(token);

    if (userResult.isSuccess) {
      // Token valid, proceed
      _isAuthenticated = true;
    } else {
      // Token expired or invalid
      await _authRepository.logout();
      _isAuthenticated = false;
    }
  }
}
```

### 2. Order Management Flow

**Create Order:**

```
1. Gather Order Information
   - Select menu items
   - Set quantities
   - Add special instructions
   - Apply promotions (if any)

2. Calculate Totals
   - Item subtotal = Σ(price × quantity)
   - Apply discounts
   - Final total = subtotal - discount

3. Validation
   - Verify all items exist
   - Check inventory availability
   - Validate quantities

4. API Submission
   - POST /orders with order data
   - Include authentication token
   - Send array of order items

5. Inventory Deduction
   - Backend reduces ingredient stock
   - Track deduction status
   - Alert on low stock

6. Order Confirmation
   - Receive order ID
   - Display order number
   - Show estimated time
```

**Update Order Status:**

```
Allowed Status Transitions:
pending → confirmed
confirmed → preparing
preparing → ready
ready → served
(Any) → cancelled

Validation:
- Only valid transitions allowed
- Chef cannot jump from "pending" to "ready"
- Waiter cannot set "preparing" status
- Admin can transition any state

Business Rules:
- Cancelled orders restore inventory
- Served orders are final
- Time tracking stored at each transition
```

### 3. Menu Item Filtering

**Filter Algorithm:**

```dart
List<MenuItem> applyFilters({
  required String? category,
  required String? dietary,
  required String? searchTerm,
  required bool? availableOnly,
  required bool? chefSpecialOnly,
}) {
  final filtered = _menuItems.where((item) {
    // 1. Category filter
    if (category != null && item.categoryId != category) {
      return false;
    }

    // 2. Dietary tags filter
    if (dietary != null && !item.dietaryTags.contains(dietary)) {
      return false;
    }

    // 3. Search filter (case-insensitive)
    if (searchTerm != null && searchTerm.isNotEmpty) {
      final term = searchTerm.toLowerCase();
      if (!item.name.toLowerCase().contains(term) &&
          !item.description.toLowerCase().contains(term)) {
        return false;
      }
    }

    // 4. Availability filter
    if (availableOnly == true && !item.availability) {
      return false;
    }

    // 5. Chef special filter
    if (chefSpecialOnly == true && !item.chefSpecial) {
      return false;
    }

    return true;
  }).toList();

  return filtered;
}
```

---

## API/Interface Specifications

### Authentication APIs

#### Login Endpoint

```
POST /auth/login
Content-Type: application/json

Request Body:
{
  "email": "chef@restaurant.com",
  "password": "securePassword123"
}

Response (200 OK):
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "_id": "64f8c2e2b8d1e5a1c2b3a4f1",
    "name": "John Chef",
    "email": "chef@restaurant.com",
    "role": "chef",
    "phone": "+1234567890",
    "isActive": true,
    "createdAt": "2024-01-15T10:30:00Z",
    "updatedAt": "2024-01-15T10:30:00Z"
  }
}

Error Responses:
400 Bad Request - Invalid email format
401 Unauthorized - Incorrect password
404 Not Found - User not registered
500 Internal Server Error - Server issue
```

**Dart Implementation:**

```dart
Future<Result<User>> login(AuthCredentials credentials) async {
  final result = await _remoteDataSource.login({
    'email': credentials.email,
    'password': credentials.password,
  });

  return result.fold(
    onSuccess: (data) async {
      final token = data['token'] as String;
      final userData = data['user'] as Map<String, dynamic>;

      // Validate response structure
      if (token.isEmpty || userData.isEmpty) {
        return ResultFailure(
          ServerFailure('Invalid response structure from server'),
        );
      }

      // Persist token
      await _localDataSource.saveAuthToken(token);
      await _localDataSource.saveUserData(userData);

      return Success(User.fromJson(userData));
    },
    onFailure: (failure) => ResultFailure(failure),
  );
}
```

### Menu APIs

#### Get All Menu Items

```
GET /menu?category={categoryId}&available={true}&chefSpecial={false}&search={query}
Authorization: Bearer {token}

Query Parameters:
- category (optional): Filter by category ID
- dietary (optional): Filter by dietary tag
- available (optional): true/false
- chefSpecial (optional): true/false
- search (optional): Search in name/description

Response (200 OK):
[
  {
    "_id": "64f8c2e2b8d1e5a1c2b3a4f5",
    "name": "Margherita Pizza",
    "description": "Classic pizza with fresh basil",
    "price": 12.99,
    "category": {
      "_id": "64f8c2e2b8d1e5a1c2b3a4f7",
      "name": "Pizzas"
    },
    "dietaryTags": ["vegetarian"],
    "availability": true,
    "preparationTime": 20,
    "chefSpecial": true,
    "imageUrl": "https://...",
    "createdAt": "2024-01-15T10:30:00Z",
    "updatedAt": "2024-01-15T10:30:00Z"
  }
]

Error Responses:
401 Unauthorized - Invalid/missing token
500 Internal Server Error
```

#### Create Menu Item

```
POST /menu
Authorization: Bearer {token}
Content-Type: application/json

Request Body:
{
  "name": "Truffle Risotto",
  "description": "Creamy risotto with black truffle",
  "price": 24.99,
  "category": "64f8c2e2b8d1e5a1c2b3a4f7",
  "dietaryTags": ["vegetarian", "gluten-free"],
  "availability": true,
  "preparationTime": 25,
  "chefSpecial": true
}

Response (201 Created):
{
  "_id": "64f8c2e2b8d1e5a1c2b3a4f9",
  "name": "Truffle Risotto",
  "description": "Creamy risotto with black truffle",
  "price": 24.99,
  "category": "64f8c2e2b8d1e5a1c2b3a4f7",
  "dietaryTags": ["vegetarian", "gluten-free"],
  "availability": true,
  "preparationTime": 25,
  "chefSpecial": true,
  "createdAt": "2024-02-12T14:20:00Z",
  "updatedAt": "2024-02-12T14:20:00Z"
}

Validation Rules:
- name: Required, max 100 characters, unique
- description: Required, max 500 characters
- price: Required, > 0, < 10000
- category: Required, must exist
- preparationTime: 1-240 minutes
- dietaryTags: Valid values listed in constants

Error Responses:
400 Bad Request - Validation error
401 Unauthorized
403 Forbidden - Insufficient permissions
409 Conflict - Duplicate name
```

### Orders APIs

#### Get Orders

```
GET /orders?status={status}&customerId={customerId}
Authorization: Bearer {token}

Query Parameters:
- status (optional): 'pending', 'confirmed', 'preparing', 'ready', 'served', 'cancelled'
- customerId (optional): Filter by customer

Response (200 OK):
[
  {
    "_id": "64f8c2e2b8d1e5a1c2b3a501",
    "items": [
      {
        "menuItem": "64f8c2e2b8d1e5a1c2b3a4f5",
        "quantity": 2,
        "price": 12.99,
        "specialInstructions": "Extra cheese"
      }
    ],
    "totalAmount": 25.98,
    "status": "confirmed",
    "customer": "64f8c2e2b8d1e5a1c2b3a4e1",
    "tableNumber": 5,
    "orderType": "dine-in",
    "orderDate": "2024-02-12T14:25:00Z",
    "createdAt": "2024-02-12T14:25:00Z",
    "updatedAt": "2024-02-12T14:30:00Z"
  }
]
```

#### Update Order Status

```
PUT /orders/{orderId}
Authorization: Bearer {token}
Content-Type: application/json

Request Body:
{
  "status": "preparing"
}

Response (200 OK):
{
  "_id": "64f8c2e2b8d1e5a1c2b3a501",
  "status": "preparing",
  "updatedAt": "2024-02-12T14:35:00Z",
  ...
}

Status Transitions Allowed:
pending → confirmed
confirmed → preparing
preparing → ready
ready → served
(Any) → cancelled

Role Restrictions:
- Chef: Can only set 'preparing' and 'ready'
- Waiter: Can only set 'confirmed' and 'served'
- Admin: Can set any status
```

---

## Setup & Deployment

### Environment Requirements

#### Development Environment

```yaml
SDK Compatibility:
  - Dart: 3.10.8+
  - Flutter: 3.10.0+
  - Platform: iOS 11.0+, Android 5.0+ (API 21+)

Required Tools:
  - Flutter SDK: Latest stable
  - Android Studio: Latest (for Android development)
  - Xcode: Latest (for iOS development)
  - Visual Studio Code: Latest (recommended editor)

System Requirements:
  - macOS 10.13+ (for iOS development)
  - Windows 10+ (for Android)
  - 4GB RAM minimum
  - 5GB free disk space
```

### Installation & Setup

#### Step 1: Clone Repository

```bash
git clone https://github.com/Zardd99/flutter_mobile_android.git
cd flutter_mobile_android
```

#### Step 2: Install Dependencies

```bash
# Get all Flutter packages
flutter pub get

# For iOS, install CocoaPods dependencies
cd ios
pod install
cd ..
```

#### Step 3: Configure Environment

Create `.env` file in project root (optional):

```
API_BASE_URL=https://nontenurial-fawn-socketless.ngrok-free.dev/api
CONNECT_TIMEOUT=15000
RECEIVE_TIMEOUT=15000
```

Update API constants in [lib/core/constants/api_constants.dart](lib/core/constants/api_constants.dart):

```dart
abstract class ApiConstants {
  static const String baseUrl = 'YOUR_API_URL';
  static const int connectTimeout = 15000;
  static const int receiveTimeout = 15000;
}
```

#### Step 4: Generate Code (if needed)

```bash
flutter pub run build_runner build
```

#### Step 5: Run Application

```bash
# Run on connected device
flutter run

# Run on emulator
flutter run -d emulator-5554

# Run with specific configuration
flutter run --debug

# Run on iOS
flutter run -d ios

# Run on Android
flutter run -d android
```

### Initialization Sequence

```dart
// main.dart
void main() async {
  // Initialize Flutter bindings
  WidgetsFlutterBinding.ensureInitialized();

  // Setup dependency injection
  await setupInjector();

  // Run application
  runApp(const RestaurantApp());
}

// RestaurantApp Widget
class RestaurantApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Initialize AuthManager - checks stored token on startup
        ChangeNotifierProvider<AuthManager>(
          create: (context) => get<AuthManager>()..initialize(),
        ),
        // Create MenuViewModel
        ChangeNotifierProvider(create: (context) => get<MenuViewModel>()),
      ],
      child: Consumer<AuthManager>(
        builder: (context, authManager, child) {
          // Route based on authentication status
          return MaterialApp(
            title: 'Restaurant Manager',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              useMaterial3: true,
            ),
            home: authManager.isAuthenticated
                ? const HomeScreen()
                : const LoginScreen(),
          );
        },
      ),
    );
  }
}
```

### Dependency Injection Setup

```dart
// injector.dart
final injector = GetIt.instance;

Future<void> setupInjector() async {
  // 1. Core services
  injector.registerLazySingleton<ApiClient>(
    () => ApiClient(baseUrl: ApiConstants.baseUrl),
  );

  // 2. Data sources
  injector.registerLazySingleton<RemoteDataSource>(
    () => RemoteDataSource(apiClient: injector()),
  );
  injector.registerLazySingleton<LocalDataSource>(() => LocalDataSourceImpl());

  // 3. Repositories
  injector.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: injector(),
      localDataSource: injector(),
    ),
  );
  injector.registerLazySingleton<MenuRepository>(
    () => MenuRepositoryImpl(injector<RemoteDataSource>()),
  );
  injector.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(injector<RemoteDataSource>()),
  );

  // 4. Use cases
  injector.registerLazySingleton<GetOrdersUseCase>(
    () => GetOrdersUseCase(injector<OrderRepository>()),
  );
  injector.registerLazySingleton<UpdateOrderStatusUseCase>(
    () => UpdateOrderStatusUseCase(injector<OrderRepository>()),
  );
  injector.registerLazySingleton<CreateMenuItemUseCase>(
    () => CreateMenuItemUseCase(injector<MenuRepository>()),
  );

  // 5. Managers (business logic coordinators)
  injector.registerLazySingleton<AuthManager>(
    () => AuthManager(authRepository: injector()),
  );
  injector.registerLazySingleton<MenuManager>(
    () => MenuManager(injector<MenuRepository>()),
  );
  injector.registerLazySingleton<OrderManager>(
    () => OrderManager(
      getOrdersUseCase: injector<GetOrdersUseCase>(),
      updateOrderStatusUseCase: injector<UpdateOrderStatusUseCase>(),
      getOrderStatsUseCase: injector<GetOrderStatsUseCase>(),
      createOrderUseCase: injector<CreateOrderUseCase>(),
    ),
  );

  // 6. ViewModels (UI state)
  injector.registerFactory<MenuViewModel>(
    () => MenuViewModel(injector<MenuManager>()),
  );
}
```

### Local Data Persistence

The application uses `SharedPreferences` for local data storage:

```dart
// Stored Keys
const String authTokenKey = 'auth_token';
const String userDataKey = 'user_data';

// Token storage (automatic on login)
await _localDataSource.saveAuthToken(token);

// User data caching
await _localDataSource.saveUserData(userData);

// Token retrieval on app startup
final token = await _localDataSource.getAuthToken();

// Clearing on logout
await _localDataSource.clearAuthData();
```

### Debugging & Logging

Enable debugging output:

```dart
// Add to main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Enable logging in debug mode
  if (kDebugMode) {
    debugPrintBeginFrameBanner = true;
    debugPrintEndFrameBanner = true;
  }

  await setupInjector();
  runApp(const RestaurantApp());
}
```

### Production Deployment

#### Android

```bash
# Build APK
flutter build apk --release

# Build App Bundle (recommended for Play Store)
flutter build appbundle --release

# Output: build/app/outputs/bundle/release/app-release.aab
```

#### iOS

```bash
# Build IPA
flutter build ios --release

# Follow Xcode upload process or use:
# fastlane pilots upload
```

---

## Conclusion

The Restaurant Mobile Application is architected with best practices for maintainability, scalability, and testability. The clean separation between presentation, domain, and data layers allows for:

- **Easy Testing:** Each layer can be tested independently
- **Feature Expansion:** New features can be added without affecting existing code
- **Maintenance:** Clear responsibility boundaries make debugging efficient
- **Performance:** Efficient data flow and minimal re-renders through optimized state management

For questions or contributions, refer to the backend documentation and API specifications provided by the backend team.

---

**Document Version:** 1.0.0  
**Last Updated:** February 12, 2026  
**Maintained By:** Architecture Team
