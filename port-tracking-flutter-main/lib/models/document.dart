class Document {
  final int id;
  final String type;
  final String? uploadedAt;
  final int ficheId;

  Document({
    required this.id,
    required this.type,
    this.uploadedAt,
    required this.ficheId,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'],
      type: json['type'] ?? '',
      uploadedAt: json['uploadedAt'],
      ficheId: json['ficheId'],
    );
  }
}