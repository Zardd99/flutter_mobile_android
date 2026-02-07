abstract class ApiConstants {
  static const String baseUrl =
      'https://nontenurial-fawn-socketless.ngrok-free.dev/api';
  // For physical device testing, replace with your computer's IP
  // static const String baseUrl = 'http://192.168.1.100:5000/api';

  static const int connectTimeout = 15000;
  static const int receiveTimeout = 15000;

  // Endpoints
  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';
  static const String authMe = '/auth/me';
  static const String authUpdate = '/auth/update';
  static const String authChangePassword = '/auth/change-password';

  static const String menu = '/menu';
  static const String categories = '/category';

  static const String orders = '/orders';
  static const String orderStats = '/orders/stats';

  static const String inventory = '/inventory';
  static const String inventoryCheck = '/inventory/check-availability';
  static const String inventoryConsume = '/inventory/consume';
  static const String inventoryLowStock = '/inventory/low-stock';
  static const String inventoryDashboard = '/inventory/dashboard';

  static const String suppliers = '/supplier';

  static const String reviews = '/reviews';
  static const String ratings = '/review/rating';

  static const String users = '/users';

  // Headers
  static const String headerContentType = 'Content-Type';
  static const String headerAuthorization = 'Authorization';
  static const String contentTypeJson = 'application/json';
}
