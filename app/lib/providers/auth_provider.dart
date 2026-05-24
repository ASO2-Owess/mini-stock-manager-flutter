import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  // État interne
  User? _user;
  String? _token;
  bool _loading = false;
  String? _error;

  // Getters — accès en lecture seule depuis l'extérieur
  User? get user => _user;
  String? get token => _token;
  bool get loading => _loading;
  String? get error => _error;
  bool get isLogged => _token != null && _user != null;
  bool get isAdmin => _user?.isAdmin ?? false;

  final AuthService _service = AuthService();

  // Chargement initial — vérifie si token existe en mémoire
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');

    if (_token != null) {
      _user = await _service.getProfil(_token!);
      if (_user == null) {
        // Token invalide ou expiré
        await _clearSession();
      }
    }
    notifyListeners();
  }

  // LOGIN
  Future<bool> login(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();

    final result = await _service.login(email, password);

    if (result.success) {
      _token = result.token;
      _user = result.user;
      await _saveSession();
    } else {
      _error = result.message;
    }

    _loading = false;
    notifyListeners();
    return result.success;
  }

  // LOGOUT
  Future<void> logout() async {
    if (_token != null) {
      await _service.logout(_token!);
    }
    await _clearSession();
    notifyListeners();
  }

  Future<bool> updateProfile({
    required String name,
    required String displayName,
    required String themeColor,
    required String avatarLabel,
  }) async {
    if (_token == null) return false;

    _loading = true;
    _error = null;
    notifyListeners();

    final result = await _service.updateProfile(_token!, {
      'name': name,
      'profile_preferences': {
        'display_name': displayName,
        'theme_color': themeColor,
        'avatar_label': avatarLabel,
      },
    });

    if (result.success && result.user != null) {
      _user = result.user;
    } else {
      _error = result.message;
    }

    _loading = false;
    notifyListeners();
    return result.success;
  }

  Future<void> logActivity(
    String action, {
    Map<String, dynamic>? metadata,
  }) async {
    final token = _token;
    if (token == null) return;
    await _service.logActivity(token, action, metadata: metadata);
  }

  // Sauvegarde token dans SharedPreferences
  Future<void> _saveSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', _token!);
  }

  // Supprime la session locale
  Future<void> _clearSession() async {
    _token = null;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }
}
