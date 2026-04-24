import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config.dart';

/// Stores and exposes the API base URL chosen by the user at runtime
/// (e.g. an ngrok URL like `https://abcd-1-2-3-4.ngrok-free.app`).
///
/// On web the base URL is always derived from the browser hostname, so this
/// service is a no-op there.
class ServerConfigService extends ChangeNotifier {
  static const _storageKey = 'api_base_url';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// Loads the persisted URL (if any) into [AppConfig].
  Future<void> load() async {
    if (kIsWeb) return;
    final stored = await _storage.read(key: _storageKey);
    if (stored != null && stored.isNotEmpty) {
      AppConfig.setBaseUrlOverride(stored);
    }
    notifyListeners();
  }

  /// Persists [url] and applies it immediately.
  ///
  /// Pass an empty string to clear the override and fall back to the
  /// compile-time default.
  Future<void> save(String url) async {
    final trimmed = _normalize(url);
    if (trimmed.isEmpty) {
      await _storage.delete(key: _storageKey);
      AppConfig.setBaseUrlOverride(null);
    } else {
      await _storage.write(key: _storageKey, value: trimmed);
      AppConfig.setBaseUrlOverride(trimmed);
    }
    notifyListeners();
  }

  /// Current effective base URL.
  String get current => AppConfig.baseUrl;

  /// Whether a user override is in effect.
  bool get hasOverride => AppConfig.hasBaseUrlOverride;

  static String _normalize(String url) {
    var u = url.trim();
    if (u.isEmpty) return '';
    // Strip trailing slashes.
    while (u.endsWith('/')) {
      u = u.substring(0, u.length - 1);
    }
    // Default to https:// if no scheme provided.
    if (!u.startsWith('http://') && !u.startsWith('https://')) {
      u = 'https://$u';
    }
    return u;
  }
}
