import '../core/api_client.dart';
import '../models/notification.dart';

class NotificationService {
  static Future<List<AppNotification>> getMyNotifications(int userId) async {
    final response = await ApiClient.dio.get(
      '/api/notifications/me?userId=$userId',
    );
    return (response.data as List)
        .map((json) => AppNotification.fromJson(json))
        .toList();
  }

  static Future<List<AppNotification>> getUnreadNotifications(int userId) async {
    final response = await ApiClient.dio.get(
      '/api/notifications/me/unread?userId=$userId',
    );
    return (response.data as List)
        .map((json) => AppNotification.fromJson(json))
        .toList();
  }

  static Future<void> markAsRead(int id) async {
    await ApiClient.dio.put('/api/notifications/$id/lu');
  }
}