/// Application configuration.
///
/// The API base URL can be:
/// - **Web**: auto-detected from the browser hostname.
/// - **Native**: read from secure storage (set by the user in the login screen)
///   or, as a fallback, the compile-time `--dart-define=API_BASE_URL=...` value.
///
/// Use `ServerConfigService` to load/save the runtime override.
library;
import 'package:flutter/foundation.dart' show kIsWeb;

class AppConfig {
  /// Compile-time default for native builds (used when no runtime override is set).
  static const String _nativeDefault = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://192.168.137.1',
  );

  /// Optional runtime override, set by ServerConfigService from secure storage.
  static String? _baseUrlOverride;

  /// Effective base URL (no trailing slash).
  static String get baseUrl {
    if (kIsWeb) {
      // Use the same hostname the browser loaded from → works from PC and phone.
      return 'https://${Uri.base.host}';
    }
    return _baseUrlOverride ?? _nativeDefault;
  }

  /// Whether a user-defined override is currently active.
  static bool get hasBaseUrlOverride => _baseUrlOverride != null;

  /// Sets (or clears with `null`) the runtime base URL override.
  /// Should only be called by ServerConfigService.
  static void setBaseUrlOverride(String? url) {
    _baseUrlOverride = (url == null || url.isEmpty) ? null : url;
  }

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
