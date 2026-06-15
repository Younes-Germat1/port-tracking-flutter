import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/inspection.dart';
import '../../services/inspection_service.dart';
import '../../widgets/app_drawer.dart';

class InspectionDetailScreen extends StatefulWidget {
  final int inspectionId;
  const InspectionDetailScreen({super.key, required this.inspectionId});

  @override
  State<InspectionDetailScreen> createState() => _InspectionDetailScreenState();
}

class _InspectionDetailScreenState extends State<InspectionDetailScreen> {
  Inspection? _inspection;
  bool _loading = true;
  final _commentCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final ins = await InspectionService.getInspectionById(widget.inspectionId);
      setState(() => _inspection = ins);
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _enregistrerResultat(String resultat) async {
    await InspectionService.enregistrerResultat(
        widget.inspectionId, resultat, _commentCtrl.text);
    await _load();
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
    final role = context.watch<AuthProvider>().user?.role ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détail Inspection',
            style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/inspections'),
        ),
      ),
      drawer: const AppDrawer(),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _inspection == null
          ? const Center(child: Text('Inspection introuvable.'))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Informations',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _infoRow('ID', '#${_inspection!.id}'),
                    _infoRow('Conteneur', '#${_inspection!.conteneurId}'),
                    _infoRow('Organisme', _inspection!.organisme ?? '-'),
                    _infoRow('Date',
                        _inspection!.date?.substring(0, 10) ?? '-'),
                    _infoRow(
                      'Résultat',
                      _resultatLabel(_inspection!.resultat),
                      valueColor: _resultatColor(_inspection!.resultat),
                    ),
                    if (_inspection!.commentaire != null &&
                        _inspection!.commentaire!.isNotEmpty)
                      _infoRow('Commentaire', _inspection!.commentaire!),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Result badge if done
            if (_inspection!.resultat != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _resultatColor(_inspection!.resultat)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _resultatColor(_inspection!.resultat)
                        .withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _inspection!.resultat == 'CONFORME'
                          ? Icons.check_circle
                          : Icons.cancel,
                      color: _resultatColor(_inspection!.resultat),
                      size: 40,
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _resultatLabel(_inspection!.resultat),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _resultatColor(_inspection!.resultat),
                          ),
                        ),
                        const Text('Inspection terminée',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),

            // Action card if pending
            if (_inspection!.resultat == null &&
                ['INSPECTEUR', 'ADII', 'ADMIN'].contains(role)) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Enregistrer le Résultat',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _commentCtrl,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: 'Commentaire optionnel...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () =>
                                  _enregistrerResultat('CONFORME'),
                              icon: const Icon(Icons.check_circle_outline),
                              label: const Text('Conforme'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF16A34A),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () =>
                                  _enregistrerResultat('NON_CONFORME'),
                              icon: const Icon(Icons.cancel_outlined),
                              label: const Text('Non Conforme'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFDC2626),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.w600, color: valueColor)),
        ],
      ),
    );
  }
}