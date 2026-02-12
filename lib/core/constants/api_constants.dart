/// Centralized API constants for the application.
///
/// This abstract class cannot be instantiated and serves only as a
/// namespace for endpoint paths, timeouts, and HTTP header constants.
/// All members are static and final.
abstract class ApiConstants {
  // ---------------------------------------------------------------------------
  // NETWORK CONFIGURATION
  // ---------------------------------------------------------------------------

  /// Base URL for all API requests.
  ///
  /// Currently points to a development tunnel (ngrok) for testing on emulators
  /// or physical devices with internet access. This URL may change with each
  /// ngrok restart – update accordingly.
  ///
  /// For physical device testing on the same local network:
  /// 1. Uncomment the alternative baseUrl.
  /// 2. Replace `192.168.1.100` with your computer's actual local IP address.
  /// 3. Ensure the backend server is running and reachable from the device.
  static const String baseUrl =
      'https://nontenurial-fawn-socketless.ngrok-free.dev/api';
  // static const String baseUrl = 'http://192.168.1.100:5000/api';

  /// Connection timeout duration in milliseconds.
  ///
  /// Defines how long the HTTP client should wait to establish a connection
  /// with the server before throwing a timeout error.
  static const int connectTimeout = 15000; // 15 seconds

  /// Receive timeout duration in milliseconds.
  ///
  /// Defines the maximum idle time between two data packets while receiving
  /// the response. If no data is received within this period, the request
  /// fails with a timeout error.
  static const int receiveTimeout = 15000; // 15 seconds

  // ---------------------------------------------------------------------------
  // AUTHENTICATION & USER MANAGEMENT
  // ---------------------------------------------------------------------------

  /// Endpoint: user login.
  /// Method: POST
  /// Request body: { "email": "...", "password": "..." }
  /// Response: { "token": "...", "user": {...} }
  static const String authLogin = '/auth/login';

  /// Endpoint: user registration.
  /// Method: POST
  /// Request body: { "name": "...", "email": "...", "password": "...", ... }
  /// Response: { "token": "...", "user": {...} }
  static const String authRegister = '/auth/register';

  /// Endpoint: fetch current authenticated user's profile.
  /// Method: GET
  /// Headers: Authorization: Bearer <token>
  /// Response: { "user": {...} }
  static const String authMe = '/auth/me';

  /// Endpoint: update current user's profile.
  /// Method: PUT / PATCH
  /// Headers: Authorization: Bearer <token>
  /// Request body: fields to update (e.g., name, email, avatar)
  static const String authUpdate = '/auth/update';

  /// Endpoint: change user password.
  /// Method: POST / PUT
  /// Headers: Authorization: Bearer <token>
  /// Request body: { "currentPassword": "...", "newPassword": "..." }
  static const String authChangePassword = '/auth/change-password';

  // ---------------------------------------------------------------------------
  // MENU & CATEGORIES
  // ---------------------------------------------------------------------------

  /// Base endpoint for menu items.
  /// Supports: GET (list), POST (create), PUT/PATCH (update), DELETE.
  /// Headers for write operations require authentication.
  static const String menu = '/menu';

  /// Base endpoint for menu categories.
  /// Supports: GET (list), POST (create), PUT/PATCH (update), DELETE.
  /// Used to organise menu items.
  static const String categories = '/category';

  // ---------------------------------------------------------------------------
  // ORDERS
  // ---------------------------------------------------------------------------

  /// Base endpoint for orders.
  /// Supports: GET (list user orders), POST (create new order),
  ///           GET /:id (order details), PUT/PATCH (update status), etc.
  /// Typically requires authentication.
  static const String orders = '/orders';

  /// Endpoint for order statistics / dashboard data.
  /// Method: GET
  /// Query parameters: ?period=day|week|month etc.
  /// Response: aggregated data (total orders, revenue, popular items, etc.)
  static const String orderStats = '/orders/stats';

  // ---------------------------------------------------------------------------
  // INVENTORY MANAGEMENT
  // ---------------------------------------------------------------------------

  /// Base endpoint for inventory items (ingredients, stock).
  /// Supports: GET, POST, PUT, DELETE.
  static const String inventory = '/inventory';

  /// Endpoint: check availability of a set of ingredients.
  /// Method: POST
  /// Request body: { "items": [{"id": "...", "quantity": ...}] }
  /// Response: { "available": boolean, "missing": [...] }
  static const String inventoryCheck = '/inventory/check-availability';

  /// Endpoint: consume/use ingredients (e.g., when an order is placed).
  /// Method: POST
  /// Request body: { "items": [{"id": "...", "quantity": ...}] }
  static const String inventoryConsume = '/inventory/consume';

  /// Endpoint: get all inventory items that are below their minimum stock level.
  /// Method: GET
  /// Response: list of low‑stock items.
  static const String inventoryLowStock = '/inventory/low-stock';

  /// Endpoint: inventory dashboard statistics.
  /// Method: GET
  /// Response: total items, value, expiring soon, etc.
  static const String inventoryDashboard = '/inventory/dashboard';

  // ---------------------------------------------------------------------------
  // SUPPLIERS
  // ---------------------------------------------------------------------------

  /// Base endpoint for suppliers.
  /// Supports full CRUD operations.
  static const String suppliers = '/supplier';

  // ---------------------------------------------------------------------------
  // REVIEWS & RATINGS
  // ---------------------------------------------------------------------------

  /// Base endpoint for customer reviews.
  /// Typically supports GET (list reviews) and POST (submit review).
  /// Often nested under menu items: /menu/{id}/reviews.
  static const String reviews = '/reviews';

  /// Endpoint for rating summary of a specific menu item.
  /// Method: GET
  /// Path: /review/rating?menuItemId=...
  /// Response: { "average": float, "count": int, "distribution": {...} }
  static const String ratings = '/review/rating';

  // ---------------------------------------------------------------------------
  // ADMIN / USER MANAGEMENT
  // ---------------------------------------------------------------------------

  /// Base endpoint for user management (admin only).
  /// Supports: GET (list users), GET /:id, POST, PUT, DELETE.
  /// Requires elevated privileges.
  static const String users = '/users';

  // ---------------------------------------------------------------------------
  // HTTP HEADERS
  // ---------------------------------------------------------------------------

  /// Standard HTTP header for specifying media type of the request/response body.
  static const String headerContentType = 'Content-Type';

  /// Authorization header carrying the Bearer token.
  /// Value format: "Bearer <JWT_token>"
  static const String headerAuthorization = 'Authorization';

  /// JSON media type value for Content-Type header.
  static const String contentTypeJson = 'application/json';
}
