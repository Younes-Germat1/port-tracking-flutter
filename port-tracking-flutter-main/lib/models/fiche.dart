class Fiche {
  final int id;
  final String statut;
  final String? importateurNom;
  final int? importateurId;
  final String? createdAt;

  Fiche({
    required this.id,
    required this.statut,
    this.importateurNom,
    this.importateurId,
    this.createdAt,
  });

  factory Fiche.fromJson(Map<String, dynamic> json) {
    return Fiche(
      id: json['id'],
      statut: json['statut'] ?? '',
      importateurNom: json['importateurNom'],
      importateurId: json['importateurId'],
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'statut': statut,
    'importateurNom': importateurNom,
    'importateurId': importateurId,
    'createdAt': createdAt,
  };
}