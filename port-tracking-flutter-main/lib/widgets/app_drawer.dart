import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final role = user?.role ?? '';

    final roleColors = {
      'ADMIN': const Color(0xFFDC2626),
      'IMPORTATEUR': const Color(0xFF2563EB),
      'ADII': const Color(0xFF16A34A),
      'OPERATEUR': const Color(0xFFD97706),
      'INSPECTEUR': const Color(0xFF7C3AED),
    };

    return Drawer(
      backgroundColor: const Color(0xFF111827),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 56, 16, 20),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFF374151)),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF2563EB),
                  radius: 22,
                  child: Text(
                    (user?.nom ?? user?.email ?? 'U')[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.nom ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: roleColors[role] ?? const Color(0xFF6B7280),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          role,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Navigation Links
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _DrawerItem(
                  icon: Icons.dashboard_outlined,
                  label: 'Dashboard',
                  route: '/dashboard',
                ),
                if (['ADMIN', 'IMPORTATEUR', 'ADII', 'OPERATEUR'].contains(role))
                  _DrawerItem(
                    icon: Icons.description_outlined,
                    label: 'Fiches Suiveuses',
                    route: '/fiches',
                  ),
                if (['ADMIN', 'OPERATEUR', 'ADII'].contains(role))
                  _DrawerItem(
                    icon: Icons.inventory_2_outlined,
                    label: 'Conteneurs',
                    route: '/conteneurs',
                  ),
                if (['ADMIN', 'ADII', 'INSPECTEUR'].contains(role))
                  _DrawerItem(
                    icon: Icons.search_outlined,
                    label: 'Inspections',
                    route: '/inspections',
                  ),
                _DrawerItem(
                  icon: Icons.notifications_outlined,
                  label: 'Notifications',
                  route: '/notifications',
                  badge: context.watch<NotificationProvider>().unreadCount,
                ),
                if (role == 'ADMIN') ...[
                  const Divider(color: Color(0xFF374151), height: 24),
                  _DrawerItem(
                    icon: Icons.people_outlined,
                    label: 'Utilisateurs',
                    route: '/admin/users',
                  ),
                ],
              ],
            ),
          ),

          // Logout
          Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFF374151))),
            ),
            child: ListTile(
              leading: const Icon(Icons.logout, color: Color(0xFF9CA3AF)),
              title: const Text(
                'Déconnexion',
                style: TextStyle(color: Color(0xFF9CA3AF)),
              ),
              onTap: () {
                context.read<AuthProvider>().logout();
                context.go('/login');
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final int badge;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.route,
    this.badge = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = GoRouterState.of(context).matchedLocation == route;

    return ListTile(
      leading: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(icon, color: isActive ? Colors.white : const Color(0xFF9CA3AF)),
          if (badge > 0)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: Color(0xFFEF4444),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  badge > 9 ? '9+' : '$badge',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.white : const Color(0xFF9CA3AF),
          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      tileColor: isActive ? const Color(0xFF2563EB) : Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      onTap: () {
        Navigator.pop(context);
        context.go(route);
      },
    );
  }
}