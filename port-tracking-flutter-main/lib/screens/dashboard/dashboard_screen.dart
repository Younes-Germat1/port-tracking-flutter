import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/fiche_provider.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/statut_badge.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = context.read<AuthProvider>();
      // Wait until user is available
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
      final user = auth.user;
      if (user != null) {
        context.read<FicheProvider>().loadFiches(
          role: user.role,
          userId: user.id,
        );
        context.read<NotificationProvider>()
          ..loadNotifications(user.id)
          ..startPolling(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final fiches = context.watch<FicheProvider>();
    final notifs = context.watch<NotificationProvider>();
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () => context.go('/notifications'),
              ),
              if (notifs.unreadCount > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Color(0xFFEF4444),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      notifs.unreadCount > 9 ? '9+' : '${notifs.unreadCount}',
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
        ],
      ),
      drawer: const AppDrawer(),
      body: fiches.loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: () => context.read<FicheProvider>().loadFiches(
          role: user?.role,
          userId: user?.id,
        ),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bonjour, ${user?.nom ?? ''} 👋',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Système de Suivi Portuaire',
                      style: TextStyle(
                        color: Color(0xFFBFDBFE),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Stats Grid
              _buildStats(context, fiches, user?.role ?? ''),
              const SizedBox(height: 24),

              // Recent Fiches
              if (user?.role != 'INSPECTEUR') ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Fiches Récentes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/fiches'),
                      child: const Text('Voir tout →'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (fiches.fiches.isEmpty)
                  const Center(
                    child: Text(
                      'Aucune fiche',
                      style: TextStyle(color: Color(0xFF9CA3AF)),
                    ),
                  )
                else
                  ...fiches.fiches.take(5).map(
                        (f) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        onTap: () => context.go('/fiches/${f.id}'),
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFFEFF6FF),
                          child: Text(
                            '#${f.id}',
                            style: const TextStyle(
                              color: Color(0xFF2563EB),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          f.importateurNom ?? 'Importateur',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          f.createdAt?.substring(0, 10) ?? '',
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: StatutBadge(statut: f.statut),
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStats(BuildContext context, FicheProvider fiches, String role) {
    if (role == 'INSPECTEUR') {
      return Row(
        children: [
          Expanded(
            child: _StatCard(
              title: 'Inspections',
              value: '1',
              icon: Icons.search,
              color: const Color(0xFF2563EB),
              bg: const Color(0xFFEFF6FF),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              title: 'Complétées',
              value: '0',
              icon: Icons.check_circle_outline,
              color: const Color(0xFF16A34A),
              bg: const Color(0xFFF0FDF4),
            ),
          ),
        ],
      );
    }

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _StatCard(
          title: 'Total Fiches',
          value: '${fiches.fiches.length}',
          icon: Icons.description_outlined,
          color: const Color(0xFF2563EB),
          bg: const Color(0xFFEFF6FF),
        ),
        _StatCard(
          title: 'En Attente',
          value: '${fiches.countByStatut('EN_ATTENTE')}',
          icon: Icons.hourglass_empty,
          color: const Color(0xFFD97706),
          bg: const Color(0xFFFFFBEB),
        ),
        _StatCard(
          title: 'Approuvées',
          value: '${fiches.countByStatut('APPROUVEE')}',
          icon: Icons.check_circle_outline,
          color: const Color(0xFF16A34A),
          bg: const Color(0xFFF0FDF4),
        ),
        _StatCard(
          title: 'Placées',
          value: '${fiches.countByStatut('PLACEE')}',
          icon: Icons.inventory_2_outlined,
          color: const Color(0xFF7C3AED),
          bg: const Color(0xFFF5F3FF),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color bg;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}