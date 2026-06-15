class AppConstants {
  static const String baseUrl = 'http://localhost:8080';  // For real device use your PC's IP: http://192.168.x.x:8080

  static const String tokenKey = 'jwt_token';
  static const String userKey = 'user_data';

  // Fiche statuts
  static const String enAttente = 'EN_ATTENTE';
  static const String approuvee = 'APPROUVEE';
  static const String rejetee = 'REJETEE';
  static const String placee = 'PLACEE';
  static const String dedouanee = 'DEDOUANEE';
  static const String liberee = 'LIBEREE';

  // User roles
  static const String admin = 'ADMIN';
  static const String importateur = 'IMPORTATEUR';
  static const String adii = 'ADII';
  static const String operateur = 'OPERATEUR';
  static const String inspecteur = 'INSPECTEUR';
}