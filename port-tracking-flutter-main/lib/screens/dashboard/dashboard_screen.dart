import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/fiche_provider.dart';
import '../../providers/notification_provider.dart';
import '../../services/inspection_service.dart';
import '../../models/inspection.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/statut_badge.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Inspection> _inspections = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = context.read<AuthProvider>();
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
      final user = auth.user;
      if (user != null) {
        if (user.role == 'INSPECTEUR') {
          final inspections = await InspectionService.getMesTaches(user.id);
          setState(() => _inspections = inspections);
        } else {
          context.read<FicheProvider>().loadFiches(
            role: user.role,
            userId: user.id,
          );
        }
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
    final role = user?.role ?? '';

    final inspectionsTodo =
    _inspections.where((i) => i.resultat == null).toList();
    final inspectionsDone =
    _inspections.where((i) => i.resultat != null).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard',
            style: TextStyle(fontWeight: FontWeight.bold)),
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
      // ✅ Bouton Scanner flottant pour INSPECTEUR
      floatingActionButton: role == 'INSPECTEUR'
          ? FloatingActionButton.extended(
        onPressed: () => context.go('/qr-scanner'),
        backgroundColor: const Color(0xFF2563EB),
        icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
        label: const Text('Scanner QR',
            style: TextStyle(color: Colors.white)),
      )
          : null,
      body: RefreshIndicator(
        onRefresh: () async {
          final user = auth.user;
          if (user?.role == 'INSPECTEUR') {
            final inspections =
            await InspectionService.getMesTaches(user!.id);
            setState(() => _inspections = inspections);
          } else {
            await context.read<FicheProvider>().loadFiches(
              role: user?.role,
              userId: user?.id,
            );
          }
        },
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

              // Stats INSPECTEUR
              if (role == 'INSPECTEUR') ...[
                Row(
                  children: [
                    Expanded(
                      child: _ClickableStatCard(
                        title: 'À Faire',
                        value: '${inspectionsTodo.length}',
                        icon: Icons.search,
                        color: const Color(0xFF2563EB),
                        bg: const Color(0xFFEFF6FF),
                        onTap: () => _showInspectionsList(
                          context,
                          'Inspections à faire',
                          inspectionsTodo,
                          false,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ClickableStatCard(
                        title: 'Complétées',
                        value: '${inspectionsDone.length}',
                        icon: Icons.check_circle_outline,
                        color: const Color(0xFF16A34A),
                        bg: const Color(0xFFF0FDF4),
                        onTap: () => _showInspectionsList(
                          context,
                          'Inspections complétées',
                          inspectionsDone,
                          true,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ✅ Bouton Scanner grand format
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () => context.go('/qr-scanner'),
                    icon: const Icon(Icons.qr_code_scanner, size: 24),
                    label: const Text(
                      'Scanner QR Code Conteneur',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],

              // Stats autres rôles
              if (role != 'INSPECTEUR') ...[
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.3,
                  children: [
                    _ClickableStatCard(
                      title: 'Total Fiches',
                      value: '${fiches.fiches.length}',
                      icon: Icons.description_outlined,
                      color: const Color(0xFF2563EB),
                      bg: const Color(0xFFEFF6FF),
                      onTap: () => context.go('/fiches'),
                    ),
                    _ClickableStatCard(
                      title: 'En Attente',
                      value: '${fiches.countByStatut('EN_ATTENTE')}',
                      icon: Icons.hourglass_empty,
                      color: const Color(0xFFD97706),
                      bg: const Color(0xFFFFFBEB),
                      onTap: () => context.go('/fiches'),
                    ),
                    _ClickableStatCard(
                      title: 'Approuvées',
                      value: '${fiches.countByStatut('APPROUVEE')}',
                      icon: Icons.check_circle_outline,
                      color: const Color(0xFF16A34A),
                      bg: const Color(0xFFF0FDF4),
                      onTap: () => context.go('/fiches'),
                    ),
                    _ClickableStatCard(
                      title: 'Placées',
                      value: '${fiches.countByStatut('PLACEE')}',
                      icon: Icons.inventory_2_outlined,
                      color: const Color(0xFF7C3AED),
                      bg: const Color(0xFFF5F3FF),
                      onTap: () => context.go('/fiches'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
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
                    child: Text('Aucune fiche',
                        style: TextStyle(color: Color(0xFF9CA3AF))),
                  )
                else
                  ...fiches.fiches.take(5).map(
                        (f) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        onTap: () => context.go('/fiches/${f.id}'),
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFFEFF6FF),
                          child: Text('#${f.id}',
                              style: const TextStyle(
                                color: Color(0xFF2563EB),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              )),
                        ),
                        title: Text(f.importateurNom ?? 'Importateur',
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14)),
                        subtitle: Text(
                            f.createdAt?.substring(0, 10) ?? '',
                            style: const TextStyle(fontSize: 12)),
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

  void _showInspectionsList(
      BuildContext context,
      String title,
      List<Inspection> inspections,
      bool completed,
      ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        builder: (_, controller) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: inspections.isEmpty
                  ? Center(
                child: Text(
                  completed
                      ? 'Aucune inspection complétée'
                      : 'Aucune inspection à faire',
                  style:
                  const TextStyle(color: Color(0xFF9CA3AF)),
                ),
              )
                  : ListView.builder(
                controller: controller,
                padding: const EdgeInsets.all(16),
                itemCount: inspections.length,
                itemBuilder: (_, i) {
                  final ins = inspections[i];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      onTap: () {
                        Navigator.pop(ctx);
                        context.go('/inspections/${ins.id}');
                      },
                      leading: CircleAvatar(
                        backgroundColor: completed
                            ? const Color(0xFFF0FDF4)
                            : const Color(0xFFEFF6FF),
                        child: Icon(
                          completed
                              ? Icons.check_circle_outline
                              : Icons.search,
                          color: completed
                              ? const Color(0xFF16A34A)
                              : const Color(0xFF2563EB),
                          size: 20,
                        ),
                      ),
                      title: Text(
                        'Conteneur #${ins.conteneurId}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        '${ins.organisme ?? '-'} • ${ins.date?.substring(0, 10) ?? ''}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: completed
                          ? Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: ins.resultat == 'CONFORME'
                              ? const Color(0xFFF0FDF4)
                              : const Color(0xFFFEF2F2),
                          borderRadius:
                          BorderRadius.circular(8),
                        ),
                        child: Text(
                          ins.resultat == 'CONFORME'
                              ? 'Conforme'
                              : 'Non Conforme',
                          style: TextStyle(
                            color: ins.resultat == 'CONFORME'
                                ? const Color(0xFF16A34A)
                                : const Color(0xFFDC2626),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                          : const Icon(Icons.arrow_forward_ios,
                          size: 14,
                          color: Color(0xFF9CA3AF)),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClickableStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color bg;
  final VoidCallback onTap;

  const _ClickableStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.bg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}