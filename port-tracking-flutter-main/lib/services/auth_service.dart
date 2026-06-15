import '../core/api_client.dart';
import '../core/auth_storage.dart';
import '../models/user.dart';

class AuthService {
  static Future<User> login(String email, String password) async {
    final response = await ApiClient.dio.post(
      '/api/auth/login',
      data: {'email': email, 'password': password},
    );

    // Backend returns: { id, token, role, email, nom }
    final data = response.data;
    await AuthStorage.saveToken(data['token']);

    return User(
      id: data['id'],
      nom: data['nom'] ?? '',
      email: data['email'] ?? email,
      role: data['role'] ?? '',
    );
  }

  static Future<void> logout() async {
    await AuthStorage.deleteToken();
    ApiClient.reset();
  }
}