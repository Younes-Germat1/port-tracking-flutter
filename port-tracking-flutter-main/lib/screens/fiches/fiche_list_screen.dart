import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/fiche_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/statut_badge.dart';

class FicheListScreen extends StatefulWidget {
  const FicheListScreen({super.key});

  @override
  State<FicheListScreen> createState() => _FicheListScreenState();
}

class _FicheListScreenState extends State<FicheListScreen> {
  String _filterStatut = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      context.read<FicheProvider>().loadFiches(
        role: auth.user?.role,
        userId: auth.user?.id,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final ficheProvider = context.watch<FicheProvider>();
    final role = auth.user?.role ?? '';

    final fiches = _filterStatut.isEmpty
        ? ficheProvider.fiches
        : ficheProvider.filterByStatut(_filterStatut);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text('Fiches Suiveuses',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (['ADII', 'ADMIN'].contains(role))
            PopupMenuButton<String>(
              icon: const Icon(Icons.filter_list),
              onSelected: (v) => setState(() => _filterStatut = v),
              itemBuilder: (_) => [
                const PopupMenuItem(value: '', child: Text('Tous')),
                const PopupMenuItem(value: 'EN_ATTENTE', child: Text('En Attente')),
                const PopupMenuItem(value: 'APPROUVEE', child: Text('Approuvée')),
                const PopupMenuItem(value: 'REJETEE', child: Text('Rejetée')),
                const PopupMenuItem(value: 'PLACEE', child: Text('Placée')),
                const PopupMenuItem(value: 'DEDOUANEE', child: Text('Dédouanée')),
              ],
            ),
        ],
      ),
      drawer: const AppDrawer(),
      floatingActionButton: role == 'IMPORTATEUR'
          ? FloatingActionButton.extended(
        onPressed: () => context.go('/fiches/create'),
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle Fiche'),
        backgroundColor: const Color(0xFF2563EB),
      )
          : null,
      body: ficheProvider.loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: () => context.read<FicheProvider>().loadFiches(
          role: auth.user?.role,
          userId: auth.user?.id,
        ),
        child: fiches.isEmpty
            ? const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.description_outlined,
                  size: 64, color: Color(0xFFD1D5DB)),
              SizedBox(height: 16),
              Text('Aucune fiche trouvée',
                  style: TextStyle(color: Color(0xFF9CA3AF))),
            ],
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: fiches.length,
          itemBuilder: (context, index) {
            final f = fiches[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
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
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  f.createdAt?.substring(0, 10) ?? '',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    StatutBadge(statut: f.statut),
                    const Icon(Icons.chevron_right,
                        color: Color(0xFF9CA3AF)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}