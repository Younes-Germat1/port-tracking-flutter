import 'package:flutter/material.dart';
import '../models/notification.dart';
import '../services/notification_service.dart';
import 'dart:async';

class NotificationProvider extends ChangeNotifier {
  List<AppNotification> _notifications = [];
  int _unreadCount = 0;
  Timer? _timer;

  List<AppNotification> get notifications => _notifications;
  int get unreadCount => _unreadCount;

  Future<void> loadNotifications(int userId) async {
    try {
      _notifications = await NotificationService.getMyNotifications(userId);
      _unreadCount = _notifications.where((n) => !n.lu).length;
      notifyListeners();
    } catch (e) {
      // silent fail
    }
  }

  Future<void> markAsRead(int id) async {
    await NotificationService.markAsRead(id);
    _notifications = _notifications
        .map((n) => n.id == id
        ? AppNotification(
      id: n.id,
      message: n.message,
      lu: true,
      createdAt: n.createdAt,
    )
        : n)
        .toList();
    _unreadCount = _notifications.where((n) => !n.lu).length;
    notifyListeners();
  }

  void startPolling(int userId) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      loadNotifications(userId);
    });
  }

  void stopPolling() {
    _timer?.cancel();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}