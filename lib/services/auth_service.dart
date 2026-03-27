import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../config.dart';

/// Manages JWT authentication: login, logout, token storage.
class AuthService extends ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String? _token;
  bool _isLoading = false;

  String? get token => _token;
  bool get isAuthenticated => _token != null;
  bool get isLoading => _isLoading;

  /// Try to restore a previously stored token on app start.
  Future<void> tryAutoLogin() async {
    final stored = await _storage.read(key: AppConfig.tokenKey);
    if (stored != null) {
      _token = stored;
      notifyListeners();
    }
  }

  /// Login with email and password. Returns null on success, or an error string.
  Future<String?> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${AppConfig.apiUrl}/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        _token = data['token'] as String?;
        if (_token != null) {
          await _storage.write(key: AppConfig.tokenKey, value: _token);
        }
        _isLoading = false;
        notifyListeners();
        return null; // success
      } else if (response.statusCode == 401) {
        _isLoading = false;
        notifyListeners();
        return 'Email ou mot de passe incorrect';
      } else if (response.statusCode == 429) {
        _isLoading = false;
        notifyListeners();
        return 'Trop de tentatives. Réessayez dans une minute.';
      } else {
        _isLoading = false;
        notifyListeners();
        return 'Erreur serveur (${response.statusCode})';
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Login error: $e');
      return 'Impossible de contacter le serveur.\n($e)';
    }
  }

  /// Clear the token and log out.
  Future<void> logout() async {
    _token = null;
    await _storage.delete(key: AppConfig.tokenKey);
    notifyListeners();
  }
}
