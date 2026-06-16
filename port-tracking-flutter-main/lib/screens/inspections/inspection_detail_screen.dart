import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
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
  final ImagePicker _picker = ImagePicker();
  List<File> _photos = [];

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

  Future<void> _takePicture() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (photo != null) {
      setState(() => _photos.add(File(photo.path)));
    }
  }

  Future<void> _pickFromGallery() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (photo != null) {
      setState(() => _photos.add(File(photo.path)));
    }
  }

  void _removePhoto(int index) {
    setState(() => _photos.removeAt(index));
  }

  Future<void> _enregistrerResultat(String resultat) async {
    await InspectionService.enregistrerResultat(
        widget.inspectionId, resultat, _commentCtrl.text);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resultat == 'CONFORME'
              ? '✅ Inspection marquée comme Conforme'
              : '❌ Inspection marquée comme Non Conforme'),
          backgroundColor: resultat == 'CONFORME'
              ? const Color(0xFF16A34A)
              : const Color(0xFFDC2626),
        ),
      );
    }
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
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
                    _infoRow('Conteneur',
                        '#${_inspection!.conteneurId}'),
                    _infoRow('Organisme',
                        _inspection!.organisme ?? '-'),
                    _infoRow('Date',
                        _inspection!.date?.substring(0, 10) ?? '-'),
                    _infoRow(
                      'Résultat',
                      _resultatLabel(_inspection!.resultat),
                      valueColor:
                      _resultatColor(_inspection!.resultat),
                    ),
                    if (_inspection!.commentaire != null &&
                        _inspection!.commentaire!.isNotEmpty)
                      _infoRow('Commentaire',
                          _inspection!.commentaire!),
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
                      color:
                      _resultatColor(_inspection!.resultat),
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
                            color: _resultatColor(
                                _inspection!.resultat),
                          ),
                        ),
                        const Text('Inspection terminée',
                            style:
                            TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),

            // Action card if pending
            if (_inspection!.resultat == null &&
                ['INSPECTEUR', 'ADII', 'ADMIN']
                    .contains(role)) ...[
              const SizedBox(height: 16),
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
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

                      // Commentaire
                      TextField(
                        controller: _commentCtrl,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Commentaire optionnel...',
                          border: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ✅ Section Photos
                      const Text('Photos comme preuve',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),

                      // Boutons photo
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _takePicture,
                              icon: const Icon(
                                  Icons.camera_alt_outlined),
                              label: const Text('Caméra'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor:
                                const Color(0xFF2563EB),
                                side: const BorderSide(
                                    color: Color(0xFF2563EB)),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _pickFromGallery,
                              icon: const Icon(
                                  Icons.photo_library_outlined),
                              label: const Text('Galerie'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor:
                                const Color(0xFF7C3AED),
                                side: const BorderSide(
                                    color: Color(0xFF7C3AED)),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Photos preview
                      if (_photos.isNotEmpty) ...[
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _photos.length,
                            itemBuilder: (_, i) => Stack(
                              children: [
                                Container(
                                  margin: const EdgeInsets
                                      .only(right: 8),
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    borderRadius:
                                    BorderRadius.circular(
                                        8),
                                    image: DecorationImage(
                                      image: FileImage(
                                          _photos[i]),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 12,
                                  child: GestureDetector(
                                    onTap: () =>
                                        _removePhoto(i),
                                    child: Container(
                                      padding:
                                      const EdgeInsets.all(
                                          2),
                                      decoration:
                                      const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 14),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_photos.length} photo(s) ajoutée(s)',
                          style: const TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 12),
                        ),
                        const SizedBox(height: 12),
                      ],

                      if (_photos.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius:
                            BorderRadius.circular(8),
                            border: Border.all(
                                color: const Color(0xFFE5E7EB),
                                style: BorderStyle.solid),
                          ),
                          child: const Column(
                            children: [
                              Icon(Icons.add_a_photo_outlined,
                                  color: Color(0xFF9CA3AF),
                                  size: 32),
                              SizedBox(height: 8),
                              Text(
                                'Ajoutez des photos comme preuve',
                                style: TextStyle(
                                    color: Color(0xFF9CA3AF),
                                    fontSize: 13),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 16),

                      // Boutons résultat
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () =>
                                  _enregistrerResultat(
                                      'CONFORME'),
                              icon: const Icon(
                                  Icons.check_circle_outline),
                              label: const Text('Conforme'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                const Color(0xFF16A34A),
                                foregroundColor: Colors.white,
                                padding:
                                const EdgeInsets.symmetric(
                                    vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () =>
                                  _enregistrerResultat(
                                      'NON_CONFORME'),
                              icon: const Icon(
                                  Icons.cancel_outlined),
                              label: const Text('Non Conforme'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                const Color(0xFFDC2626),
                                foregroundColor: Colors.white,
                                padding:
                                const EdgeInsets.symmetric(
                                    vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(8),
                                ),
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