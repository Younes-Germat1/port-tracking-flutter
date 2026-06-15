import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/conteneur.dart';
import '../../services/conteneur_service.dart';

class ConteneurDetailScreen extends StatefulWidget {
  final int conteneurId;
  const ConteneurDetailScreen({super.key, required this.conteneurId});

  @override
  State<ConteneurDetailScreen> createState() => _ConteneurDetailScreenState();
}

class _ConteneurDetailScreenState extends State<ConteneurDetailScreen> {
  Conteneur? _conteneur;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final c = await ConteneurService.getConteneurById(widget.conteneurId);
      setState(() => _conteneur = c);
    } finally {
      setState(() => _loading = false);
    }
  }

  Widget _infoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF6B7280)),
          const SizedBox(width: 12),
          Text(label,
              style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14)),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Color(0xFF1F2937))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/conteneurs'),
        ),
        title: Text('Conteneur #${widget.conteneurId}',
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Status card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Conteneur #${_conteneur?.id}',
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        Text('Fiche #${_conteneur?.ficheId}',
                            style: const TextStyle(
                                color: Color(0xFF6B7280))),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1FAE5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _conteneur?.statut ?? '',
                        style: const TextStyle(
                            color: Color(0xFF065F46),
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Location info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Emplacement',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const Divider(),
                    _infoRow('Zone', _conteneur?.zone ?? '-',
                        Icons.location_on_outlined),
                    _infoRow('Rangée', _conteneur?.rangee ?? '-',
                        Icons.grid_on_outlined),
                    _infoRow('Position', _conteneur?.position ?? '-',
                        Icons.pin_drop_outlined),
                    _infoRow('Quai', _conteneur?.quai ?? '-',
                        Icons.anchor_outlined),
                    const Divider(),
                    _infoRow(
                        'Dwell Time',
                        '${_conteneur?.dwellTimeHours ?? 0}h',
                        Icons.access_time),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}