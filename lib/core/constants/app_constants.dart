abstract class AppConstants {
  static const String appName = 'Restaurant Manager';

  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String themeModeKey = 'theme_mode';

  static const int defaultPageSize = 20;
  static const int dashboardPageSize = 10;

  // Status
  static const List<String> orderStatuses = [
    'pending',
    'confirmed',
    'preparing',
    'ready',
    'served',
    'cancelled',
  ];

  // Roles
  static const List<String> roles = [
    'admin',
    'manager',
    'chef',
    'waiter',
    'cashier',
    'customer',
  ];
}
