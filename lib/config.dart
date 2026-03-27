/// Application configuration.
///
/// Change [baseUrl] to your server's local IP when testing on a real device.
/// Example: https://192.168.1.42
class AppConfig {
  /// Base URL of the Symfony API (no trailing slash).
  /// PC hotspot IP — phone connects directly to PC via mobile hotspot.
  static const String baseUrl = 'https://192.168.137.1';

  /// API prefix.
  static const String apiPrefix = '/api';

  /// Full API base URL.
  static String get apiUrl => '$baseUrl$apiPrefix';

  /// JWT token key used in secure storage.
  static const String tokenKey = 'jwt_token';

  /// Items per page returned by the API.
  static const int itemsPerPage = 20;

  /// Notification items per page.
  static const int notificationsPerPage = 30;
}
