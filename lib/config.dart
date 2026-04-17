/// Application configuration.
///
/// Change [baseUrl] to your server's local IP when testing on a real device.
/// Example: https://192.168.1.42
library;
import 'package:flutter/foundation.dart' show kIsWeb;

class AppConfig {
  /// Base URL of the Symfony API (no trailing slash).
  ///
  /// - **Web**: auto-detected from the browser's current hostname so the app
  ///   works from any device (PC, phone, tablet) without rebuilding.
  /// - **Native**: uses --dart-define=API_BASE_URL or falls back to the
  ///   PC hotspot IP.
  static String get baseUrl {
    if (kIsWeb) {
      // Use the same hostname the browser loaded from → works from PC and phone.
      return 'https://${Uri.base.host}';
    }
    return _nativeBaseUrl;
  }

  /// Compile-time constant for native builds only.
  static const String _nativeBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://192.168.137.1',
  );

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
