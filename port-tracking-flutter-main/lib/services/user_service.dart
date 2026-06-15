import '../core/api_client.dart';
import '../models/user.dart';

class UserService {
  static Future<List<User>> getAllUsers() async {
    final response = await ApiClient.dio.get('/api/admin/users');
    return (response.data as List)
        .map((json) => User.fromJson(json))
        .toList();
  }

  static Future<User> createUser(
      String nom,
      String email,
      String password,
      String role,
      ) async {
    final response = await ApiClient.dio.post(
      '/api/auth/register?role=$role',
      data: {
        'nom': nom,
        'email': email,
        'password': password,
      },
    );
    return User.fromJson(response.data);
  }
}