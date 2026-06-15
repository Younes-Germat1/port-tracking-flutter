class Conteneur {
  final int id;
  final String statut;
  final String? zone;
  final String? rangee;
  final String? position;
  final String? quai;
  final int? dwellTimeHours;
  final int? ficheId;

  Conteneur({
    required this.id,
    required this.statut,
    this.zone,
    this.rangee,
    this.position,
    this.quai,
    this.dwellTimeHours,
    this.ficheId,
  });

  factory Conteneur.fromJson(Map<String, dynamic> json) {
    return Conteneur(
      id: json['id'],
      statut: json['statut'] ?? '',
      zone: json['zone'],
      rangee: json['rangee'],
      position: json['position'],
      quai: json['quai'],
      dwellTimeHours: json['dwellTimeHours'],
      ficheId: json['ficheId'],
    );
  }
}