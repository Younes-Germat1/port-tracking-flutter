import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/app_drawer.dart';

class NotificationListScreen extends StatefulWidget {
  const NotificationListScreen({super.key});

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        context.read<NotificationProvider>().loadNotifications(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifs = context.watch<NotificationProvider>();
    final unread = notifs.notifications.where((n) => !n.lu).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications',
            style: TextStyle(fontWeight: FontWeight.bold)),
        // ✅ Bouton retour vers dashboard
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
        actions: [
          if (unread > 0)
            TextButton(
              onPressed: () {
                for (final n in notifs.notifications.where((n) => !n.lu)) {
                  notifs.markAsRead(n.id);
                }
              },
              child: const Text('Tout lire'),
            ),
        ],
      ),
      drawer: const AppDrawer(),
      body: notifs.notifications.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none,
                size: 64, color: Color(0xFFD1D5DB)),
            SizedBox(height: 16),
            Text('Aucune notification',
                style: TextStyle(color: Color(0xFF9CA3AF))),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifs.notifications.length,
        itemBuilder: (_, i) {
          final n = notifs.notifications[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: n.lu
                    ? const Color(0xFFE5E7EB)
                    : const Color(0xFF2563EB),
                width: n.lu ? 1 : 1.5,
              ),
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: n.lu
                      ? const Color(0xFFF3F4F6)
                      : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.notifications_outlined,
                  color: n.lu
                      ? const Color(0xFF9CA3AF)
                      : const Color(0xFF2563EB),
                  size: 20,
                ),
              ),
              title: Text(
                n.message,
                style: TextStyle(
                  fontWeight:
                  n.lu ? FontWeight.normal : FontWeight.w600,
                  fontSize: 13,
                  color: n.lu
                      ? const Color(0xFF6B7280)
                      : const Color(0xFF1F2937),
                ),
              ),
              subtitle: n.createdAt != null
                  ? Text(
                n.createdAt!
                    .substring(0, 16)
                    .replaceAll('T', ' '),
                style: const TextStyle(fontSize: 11),
              )
                  : null,
              trailing: !n.lu
                  ? TextButton(
                onPressed: () => notifs.markAsRead(n.id),
                child: const Text('Lu',
                    style: TextStyle(fontSize: 12)),
              )
                  : const Icon(Icons.check_circle,
                  color: Color(0xFF16A34A), size: 18),
            ),
          );
        },
      ),
    );
  }
}