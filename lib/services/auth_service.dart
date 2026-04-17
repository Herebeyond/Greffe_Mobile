import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../config.dart';

/// Manages JWT authentication: login, logout, token storage.
class AuthService extends ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String? _token;
  String? _fullName;
  List<String> _roles = [];
  bool _isLoading = false;

  String? get token => _token;
  String? get fullName => _fullName;
  List<String> get roles => _roles;
  bool get isNurse => _roles.contains('ROLE_NURSE') && !_roles.contains('ROLE_DOCTOR');
  bool get isDoctor => _roles.contains('ROLE_DOCTOR');
  bool get isAuthenticated => _token != null;
  bool get isLoading => _isLoading;

  /// Try to restore a previously stored token on app start.
  Future<void> tryAutoLogin() async {
    final stored = await _storage.read(key: AppConfig.tokenKey);
    final storedName = await _storage.read(key: '${AppConfig.tokenKey}_fullName');
    final storedRoles = await _storage.read(key: '${AppConfig.tokenKey}_roles');
    if (stored != null) {
      _token = stored;
      _fullName = storedName;
      if (storedRoles != null) {
        _roles = storedRoles.split(',').where((r) => r.isNotEmpty).toList();
      }
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
        _fullName = data['fullName'] as String?;
        final rawRoles = data['roles'];
        if (rawRoles is List) {
          _roles = rawRoles.map((r) => r.toString()).toList();
        } else {
          _roles = [];
        }
        if (_token != null) {
          await _storage.write(key: AppConfig.tokenKey, value: _token);
          if (_fullName != null) {
            await _storage.write(key: '${AppConfig.tokenKey}_fullName', value: _fullName);
          }
          await _storage.write(
            key: '${AppConfig.tokenKey}_roles',
            value: _roles.join(','),
          );
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
    _fullName = null;
    _roles = [];
    await _storage.delete(key: AppConfig.tokenKey);
    await _storage.delete(key: '${AppConfig.tokenKey}_fullName');
    await _storage.delete(key: '${AppConfig.tokenKey}_roles');
    notifyListeners();
  }
}
