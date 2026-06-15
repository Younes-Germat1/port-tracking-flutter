import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/inspection.dart';
import '../../models/fiche.dart';
import '../../models/conteneur.dart';
import '../../services/inspection_service.dart';
import '../../services/fiche_service.dart';
import '../../services/conteneur_service.dart';
import '../../services/user_service.dart';
import '../../models/user.dart';
import '../../widgets/app_drawer.dart';

class InspectionListScreen extends StatefulWidget {
  const InspectionListScreen({super.key});

  @override
  State<InspectionListScreen> createState() => _InspectionListScreenState();
}

class _InspectionListScreenState extends State<InspectionListScreen> {
  List<Inspection> _inspections = [];
  List<Fiche> _fiches = [];
  List<Conteneur> _conteneurs = [];
  List<User> _inspecteurs = [];
  bool _loading = true;

  int? _selectedFicheId;
  int? _selectedConteneurId;
  int? _selectedInspecteurId;
  String _organisme = 'ADII';
  bool _showCreateForm = false;

  final _commentCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final auth = context.read<AuthProvider>();
    final role = auth.user?.role ?? '';
    try {
      if (role == 'INSPECTEUR') {
        _inspections = await InspectionService.getMesTaches(auth.user!.id);
      } else {
        _inspections = await InspectionService.getAllInspections();
      }
      if (['ADII', 'ADMIN'].contains(role)) {
        final allFiches = await FicheService.getAllFiches();
        _fiches = allFiches;
        try {
          final users = await UserService.getAllUsers();
          _inspecteurs = users.where((u) => u.role == 'INSPECTEUR').toList();
        } catch (e) {
          print('DEBUG users error: $e');
        }
      }
    } catch (e) {
      print('DEBUG load error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _createInspection() async {
    if (_selectedConteneurId == null || _selectedInspecteurId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner tous les champs')),
      );
      return;
    }
    await InspectionService.createInspection(
        _selectedConteneurId!, _selectedInspecteurId!, _organisme);
    setState(() => _showCreateForm = false);
    await _load();
  }

  void _showResultModal(int inspectionId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (modalContext) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Enregistrer Résultat',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: _commentCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                  hintText: 'Commentaire optionnel...'),
            ),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await InspectionService.enregistrerResultat(
                        inspectionId, 'CONFORME', _commentCtrl.text);
                    _commentCtrl.clear();
                    Navigator.of(modalContext).pop();
                    await _load();
                  },
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Conforme'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await InspectionService.enregistrerResultat(
                        inspectionId, 'NON_CONFORME', _commentCtrl.text);
                    _commentCtrl.clear();
                    Navigator.of(modalContext).pop();
                    await _load();
                  },
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Non Conforme'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626)),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Color _resultatColor(String? r) {
    if (r == 'CONFORME') return const Color(0xFF16A34A);
    if (r == 'NON_CONFORME') return const Color(0xFFDC2626);
    return const Color(0xFFD97706);
  }

  String _resultatLabel(String? r) {
    if (r == 'CONFORME') return 'Conforme';
    if (r == 'NON_CONFORME') return 'Non Conforme';
    return 'En Attente';
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final role = auth.user?.role ?? '';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text('Inspections',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      drawer: const AppDrawer(),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          if (['ADII', 'ADMIN'].contains(role))
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Créer une Inspection',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextButton.icon(
                        onPressed: () => setState(
                                () => _showCreateForm = !_showCreateForm),
                        icon: Icon(_showCreateForm
                            ? Icons.close
                            : Icons.add),
                        label: Text(_showCreateForm
                            ? 'Annuler'
                            : 'Nouvelle'),
                      ),
                    ],
                  ),
                  if (_showCreateForm) ...[
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      value: _selectedFicheId,
                      decoration:
                      const InputDecoration(labelText: 'Fiche'),
                      items: _fiches
                          .map((f) => DropdownMenuItem(
                        value: f.id,
                        child: Text(
                            'Fiche #${f.id} — ${f.importateurNom ?? ''}'),
                      ))
                          .toList(),
                      onChanged: (v) async {
                        setState(() => _selectedFicheId = v);
                        if (v != null) {
                          final c = await ConteneurService
                              .getConteneursByFiche(v);
                          setState(() {
                            _conteneurs = c;
                            _selectedConteneurId = null;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      value: _selectedConteneurId,
                      decoration: const InputDecoration(
                          labelText: 'Conteneur'),
                      items: _conteneurs
                          .map((c) => DropdownMenuItem(
                        value: c.id,
                        child: Text('Conteneur #${c.id}'),
                      ))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _selectedConteneurId = v),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      value: _selectedInspecteurId,
                      decoration: const InputDecoration(
                          labelText: 'Inspecteur'),
                      items: _inspecteurs
                          .map((u) => DropdownMenuItem<int>(
                        value: u.id,
                        child: Text(u.nom),
                      ))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _selectedInspecteurId = v),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _organisme,
                      decoration: const InputDecoration(
                          labelText: 'Organisme'),
                      items: ['ADII', 'ONSSA', 'AMSSNUR', 'AUTRES']
                          .map((o) => DropdownMenuItem(
                          value: o, child: Text(o)))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _organisme = v ?? 'ADII'),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _createInspection,
                        child: const Text("Créer l'Inspection"),
                      ),
                    ),
                  ],
                ],
              ),
            ),

          Expanded(
            child: _inspections.isEmpty
                ? const Center(
                child: Text('Aucune inspection',
                    style: TextStyle(color: Color(0xFF9CA3AF))))
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _inspections.length,
              itemBuilder: (_, i) {
                final ins = _inspections[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    onTap: () => GoRouter.of(context).push('/inspections/${ins.id}'),
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFFEFF6FF),
                      child: Text('#${ins.id}',
                          style: const TextStyle(
                              color: Color(0xFF2563EB),
                              fontSize: 11,
                              fontWeight: FontWeight.bold)),
                    ),
                    title: Text(
                        'Conteneur #${ins.conteneurId}  •  ${ins.organisme ?? '-'}'),
                    subtitle: Text(
                        ins.date?.substring(0, 10) ?? ''),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _resultatColor(ins.resultat)
                                .withOpacity(0.1),
                            borderRadius:
                            BorderRadius.circular(8),
                          ),
                          child: Text(
                            _resultatLabel(ins.resultat),
                            style: TextStyle(
                              color: _resultatColor(ins.resultat),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (ins.resultat == null &&
                            ['INSPECTEUR', 'ADII', 'ADMIN']
                                .contains(role))
                          IconButton(
                            icon: const Icon(
                                Icons.edit_note_outlined,
                                color: Color(0xFF2563EB)),
                            onPressed: () =>
                                _showResultModal(ins.id),
                          ),
                      ],
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