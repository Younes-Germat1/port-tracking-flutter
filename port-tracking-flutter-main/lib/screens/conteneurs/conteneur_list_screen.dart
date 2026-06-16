import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/conteneur.dart';
import '../../models/fiche.dart';
import '../../services/conteneur_service.dart';
import '../../services/fiche_service.dart';
import '../../widgets/app_drawer.dart';

class ConteneurListScreen extends StatefulWidget {
  const ConteneurListScreen({super.key});

  @override
  State<ConteneurListScreen> createState() => _ConteneurListScreenState();
}

class _ConteneurListScreenState extends State<ConteneurListScreen> {
  List<Fiche> _fiches = [];
  List<Conteneur> _conteneurs = [];
  int? _selectedFicheId;
  bool _loadingFiches = true;
  bool _loadingConteneurs = false;

  @override
  void initState() {
    super.initState();
    _loadFiches();
  }

  Future<void> _loadFiches() async {
    try {
      final fiches = await FicheService.getAllFiches();
      setState(() => _fiches = fiches.where((f) =>
          ['APPROUVEE', 'PLACEE', 'DEDOUANEE'].contains(f.statut)).toList());
    } finally {
      setState(() => _loadingFiches = false);
    }
  }

  Future<void> _loadConteneurs(int ficheId) async {
    setState(() {
      _selectedFicheId = ficheId;
      _loadingConteneurs = true;
    });
    try {
      final list = await ConteneurService.getConteneursByFiche(ficheId);
      setState(() => _conteneurs = list);
    } finally {
      setState(() => _loadingConteneurs = false);
    }
  }

  Color _statutColor(String s) {
    switch (s) {
      case 'STOCKE': return const Color(0xFF16A34A);
      case 'EN_INSPECTION': return const Color(0xFFD97706);
      case 'ARRIVE': return const Color(0xFF2563EB);
      default: return const Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
        title: const Text('Conteneurs',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      drawer: const AppDrawer(),
      body: _loadingFiches
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: DropdownButtonFormField<int>(
              value: _selectedFicheId,
              decoration: const InputDecoration(
                labelText: 'Sélectionner une fiche',
                prefixIcon: Icon(Icons.description_outlined),
              ),
              items: _fiches
                  .map((f) => DropdownMenuItem(
                value: f.id,
                child: Text(
                    'Fiche #${f.id} — ${f.importateurNom} (${f.statut})'),
              ))
                  .toList(),
              onChanged: (v) {
                if (v != null) _loadConteneurs(v);
              },
            ),
          ),
          Expanded(
            child: _selectedFicheId == null
                ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined,
                      size: 64, color: Color(0xFFD1D5DB)),
                  SizedBox(height: 16),
                  Text('Sélectionnez une fiche',
                      style:
                      TextStyle(color: Color(0xFF9CA3AF))),
                ],
              ),
            )
                : _loadingConteneurs
                ? const Center(child: CircularProgressIndicator())
                : _conteneurs.isEmpty
                ? const Center(
              child: Text('Aucun conteneur',
                  style: TextStyle(
                      color: Color(0xFF9CA3AF))),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _conteneurs.length,
              itemBuilder: (_, i) {
                final c = _conteneurs[i];
                return Card(
                  margin:
                  const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    onTap: () => context
                        .go('/conteneurs/${c.id}'),
                    leading: CircleAvatar(
                      backgroundColor:
                      const Color(0xFFEFF6FF),
                      child: Text('#${c.id}',
                          style: const TextStyle(
                              color: Color(0xFF2563EB),
                              fontSize: 11,
                              fontWeight:
                              FontWeight.bold)),
                    ),
                    title: Text(
                        'Zone: ${c.zone ?? '-'} | Rangée: ${c.rangee ?? '-'}'),
                    subtitle: Text(
                        'Position: ${c.position ?? '-'} | Quai: ${c.quai ?? '-'}'),
                    trailing: Container(
                      padding:
                      const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4),
                      decoration: BoxDecoration(
                        color: _statutColor(c.statut)
                            .withOpacity(0.1),
                        borderRadius:
                        BorderRadius.circular(8),
                      ),
                      child: Text(
                        c.statut,
                        style: TextStyle(
                          color:
                          _statutColor(c.statut),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}