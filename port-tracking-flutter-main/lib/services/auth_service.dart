import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../core/auth_storage.dart';
import '../core/constants.dart';
import '../models/user.dart';

class AuthService {
  static Future<User> login(String email, String password) async {
    try {
      final response = await ApiClient.dio.post(
        '/api/auth/login',
        data: {'email': email, 'password': password},
      );

      final data = response.data as Map<String, dynamic>;

      await AuthStorage.saveToken(data['token']);

      return User(
        id: data['id'] ?? 0,
        nom: data['nom'] ?? '',
        email: data['email'] ?? email,
        role: data['role'] ?? '',
        token: data['token'] ?? '',
      );
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 401 || status == 403) {
        throw Exception('Email ou mot de passe incorrect.');
      } else if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Serveur inaccessible. Vérifiez votre connexion.');
      } else {
        throw Exception('Erreur: ${e.message}');
      }
    }
  }

  static Future<void> logout() async {
    await AuthStorage.deleteToken();
    ApiClient.reset();
  }
}