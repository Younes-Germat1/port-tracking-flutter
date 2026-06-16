class User {
  final int id;
  final String nom;
  final String email;
  final String role;
  final String token;

  User({
    required this.id,
    required this.nom,
    required this.email,
    required this.role,
    this.token = '',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      nom: json['nom'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      token: json['token'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nom': nom,
    'email': email,
    'role': role,
    'token': token,
  };
}