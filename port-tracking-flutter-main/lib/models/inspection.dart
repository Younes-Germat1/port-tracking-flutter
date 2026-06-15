class Inspection {
  final int id;
  final int conteneurId;
  final int? inspecteurId;
  final String? inspecteurNom;
  final String? organisme;
  final String? resultat;
  final String? date;
  final String? commentaire;

  Inspection({
    required this.id,
    required this.conteneurId,
    this.inspecteurId,
    this.inspecteurNom,
    this.organisme,
    this.resultat,
    this.date,
    this.commentaire,
  });

  factory Inspection.fromJson(Map<String, dynamic> json) {
    return Inspection(
      id: json['id'],
      conteneurId: json['conteneurId'],
      inspecteurId: json['inspecteurId'],
      inspecteurNom: json['inspecteurNom'],
      organisme: json['organisme'],
      resultat: json['resultat'],
      date: json['date'],
      commentaire: json['commentaire'],
    );
  }
}