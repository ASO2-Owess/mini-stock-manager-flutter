import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/user.dart';

// Résultat d'une opération auth
// Contient soit un succès soit une erreur
class AuthResult {
  final bool success;
  final String message;
  final String? token;
  final User? user;

  AuthResult({
    required this.success,
    required this.message,
    this.token,
    this.user,
  });
}

class AuthService {
  // LOGIN
  Future<AuthResult> login(String email, String password) async {
    try {
      // Envoie une requête POST à l'API Laravel
      final response = await http.post(
        Uri.parse(ApiConfig.login),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      // Décode la réponse JSON
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return AuthResult(
          success: true,
          message: data['message'],
          token: data['token'],
          user: User.fromJson(data['user']),
        );
      } else {
        return AuthResult(
          success: false,
          message: data['message'] ?? 'Erreur de connexion',
        );
      }
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Erreur réseau : $e',
      );
    }
  }

  // LOGOUT
  Future<bool> logout(String token) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.logout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // GET PROFIL
  Future<User?> getProfil(String token) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.profile),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<AuthResult> updateProfile(
    String token,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await http.put(
        Uri.parse(ApiConfig.profile),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      final body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return AuthResult(
          success: true,
          message: body['message'],
          user: User.fromJson(body['user']),
        );
      }

      return AuthResult(
        success: false,
        message: body['message'] ?? 'Modification impossible',
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Erreur reseau : $e',
      );
    }
  }

  Future<void> logActivity(
    String token,
    String action, {
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await http.post(
        Uri.parse(ApiConfig.activities),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'action': action,
          'metadata': metadata ?? {},
        }),
      );
    } catch (_) {
      // Activity tracking must never block the user flow.
    }
  }
}
