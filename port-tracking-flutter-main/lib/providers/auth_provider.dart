import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../core/auth_storage.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  User? _user;
  AuthStatus _status = AuthStatus.unknown;
  String? _error;

  User? get user => _user;
  AuthStatus get status => _status;
  String? get error => _error;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  Future<void> login(String email, String password) async {
    try {
      _error = null;
      _user = await AuthService.login(email, password);
      _status = AuthStatus.authenticated;
      notifyListeners();
    } catch (e) {
      _error = e.toString(); // ← affiche l'erreur exacte
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await AuthService.logout();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> checkAuth() async {
    await AuthStorage.deleteToken();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  bool hasRole(String role) => _user?.role == role;
  bool canAccessFiches() =>
      ['ADMIN', 'IMPORTATEUR', 'ADII', 'OPERATEUR'].contains(_user?.role);
  bool canAccessInspections() =>
      ['ADMIN', 'ADII', 'INSPECTEUR'].contains(_user?.role);
  bool canAccessAdmin() => _user?.role == 'ADMIN';
}