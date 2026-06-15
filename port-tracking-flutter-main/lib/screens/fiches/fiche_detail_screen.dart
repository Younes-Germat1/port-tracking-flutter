import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/fiche_provider.dart';
import '../../models/fiche.dart';
import '../../services/fiche_service.dart';
import '../../services/conteneur_service.dart';
import '../../widgets/statut_badge.dart';

class FicheDetailScreen extends StatefulWidget {
  final int ficheId;
  const FicheDetailScreen({super.key, required this.ficheId});

  @override
  State<FicheDetailScreen> createState() => _FicheDetailScreenState();
}

class _FicheDetailScreenState extends State<FicheDetailScreen> {
  Fiche? _fiche;
  List<dynamic> _historique = [];
  bool _loading = true;

  // Placement form
  final _zoneCtrl = TextEditingController();
  final _rangeeCtrl = TextEditingController();
  final _positionCtrl = TextEditingController();
  final _quaiCtrl = TextEditingController();
  bool _placementLoading = false;

  // Reject
  final _rejectCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFiche();
  }

  Future<void> _loadFiche() async {
    setState(() => _loading = true);
    try {
      final fiche = await FicheService.getFicheById(widget.ficheId);
      final hist = await FicheService.getHistorique(widget.ficheId);
      setState(() {
        _fiche = fiche;
        _historique = hist;
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _updateStatut(String statut) async {
    final auth = context.read<AuthProvider>();
    await FicheService.updateStatut(widget.ficheId, statut, auth.user!.id);
    await _loadFiche();
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _placer() async {
    if (_zoneCtrl.text.isEmpty || _rangeeCtrl.text.isEmpty ||
        _positionCtrl.text.isEmpty || _quaiCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tous les champs sont obligatoires')),
      );
      return;
    }
    setState(() => _placementLoading = true);
    try {
      final cont = await ConteneurService.createConteneur(widget.ficheId);
      await ConteneurService.assignEmplacement(
        cont.id,
        _zoneCtrl.text,
        _rangeeCtrl.text,
        _positionCtrl.text,
        _quaiCtrl.text,
      );
      final auth = context.read<AuthProvider>();
      await FicheService.updateStatut(widget.ficheId, 'PLACEE', auth.user!.id);
      await _loadFiche();
      if (mounted) Navigator.of(context).pop();
    } finally {
      setState(() => _placementLoading = false);
    }
  }

  void _showPlacementModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Assigner Emplacement',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _field(_zoneCtrl, 'Zone', 'ex: A')),
              const SizedBox(width: 12),
              Expanded(child: _field(_rangeeCtrl, 'Rangée', 'ex: 12')),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _field(_positionCtrl, 'Position', 'ex: 05')),
              const SizedBox(width: 12),
              Expanded(child: _field(_quaiCtrl, 'Quai', 'ex: Q3')),
            ]),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _placementLoading ? null : _placer,
              child: _placementLoading
                  ? const SizedBox(width: 20, height: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Confirmer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, String hint) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(labelText: label, hintText: hint),
    );
  }

  void _showRejectModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Motif de Rejet',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: _rejectCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Expliquez le motif du rejet...',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
              onPressed: () => _updateStatut('REJETEE'),
              child: const Text('Confirmer le Rejet'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final role = auth.user?.role ?? '';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/fiches'),
        ),
        title: Text('Fiche #${widget.ficheId}',
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadFiche,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Fiche #${_fiche?.id}',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          StatutBadge(statut: _fiche?.statut ?? ''),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Importateur: ${_fiche?.importateurNom ?? ''}',
                          style: const TextStyle(color: Color(0xFF6B7280))),
                      if (_fiche?.createdAt != null)
                        Text('Créée le: ${_fiche!.createdAt!.substring(0, 10)}',
                            style: const TextStyle(
                                color: Color(0xFF9CA3AF), fontSize: 12)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Action Buttons
              if (['ADII', 'ADMIN'].contains(role) &&
                  _fiche?.statut == 'EN_ATTENTE') ...[
                Row(children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _updateStatut('APPROUVEE'),
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Approuver'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF16A34A)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _showRejectModal,
                      icon: const Icon(Icons.cancel_outlined),
                      label: const Text('Rejeter'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDC2626)),
                    ),
                  ),
                ]),
                const SizedBox(height: 12),
              ],

              if (['OPERATEUR', 'ADMIN'].contains(role) &&
                  _fiche?.statut == 'APPROUVEE') ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _showPlacementModal,
                    icon: const Icon(Icons.location_on_outlined),
                    label: const Text('Assigner Emplacement'),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Historique
              const Text('Historique',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Card(
                child: _historique.isEmpty
                    ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Aucun historique',
                      style: TextStyle(color: Color(0xFF9CA3AF))),
                )
                    : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _historique.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final h = _historique[i];
                    return ListTile(
                      leading: const CircleAvatar(
                        radius: 6,
                        backgroundColor: Color(0xFF2563EB),
                      ),
                      title: Text(h['action'] ?? '',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13)),
                      subtitle: Text(h['details'] ?? '',
                          style: const TextStyle(fontSize: 12)),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}