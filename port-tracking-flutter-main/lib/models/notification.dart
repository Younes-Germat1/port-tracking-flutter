class AppNotification {
  final int id;
  final String message;
  final bool lu;
  final String? createdAt;

  AppNotification({
    required this.id,
    required this.message,
    required this.lu,
    this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      message: json['message'] ?? '',
      lu: json['lu'] ?? false,
      createdAt: json['createdAt'],
    );
  }
}