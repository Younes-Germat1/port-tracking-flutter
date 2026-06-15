import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../services/fiche_service.dart';

class CreateFicheScreen extends StatefulWidget {
  const CreateFicheScreen({super.key});

  @override
  State<CreateFicheScreen> createState() => _CreateFicheScreenState();
}

class _CreateFicheScreenState extends State<CreateFicheScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  // Marchandise fields
  final _poidsCtrl = TextEditingController();
  final _volumeCtrl = TextEditingController();
  final _codeShCtrl = TextEditingController();
  String _classification = 'STANDARD';

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final auth = context.read<AuthProvider>();
      await FicheService.createFiche({
        'importateurId': auth.user!.id,
        'marchandises': [
          {
            'poids': double.tryParse(_poidsCtrl.text) ?? 0,
            'volume': double.tryParse(_volumeCtrl.text) ?? 0,
            'codeSh': _codeShCtrl.text,
            'classification': _classification,
          }
        ],
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fiche créée avec succès!'),
            backgroundColor: Color(0xFF16A34A),
          ),
        );
        context.go('/fiches');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la création'),
            backgroundColor: Color(0xFFDC2626),
          ),
        );
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/fiches'),
        ),
        title: const Text('Nouvelle Fiche',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Marchandise Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Marchandise',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),

                      // Classification
                      DropdownButtonFormField<String>(
                        value: _classification,
                        decoration: const InputDecoration(
                          labelText: 'Classification',
                        ),
                        items: ['STANDARD', 'DANGEREUSE', 'PERISSABLE', 'FRAGILE']
                            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _classification = v ?? 'STANDARD'),
                      ),
                      const SizedBox(height: 12),

                      Row(children: [
                        Expanded(
                          child: TextFormField(
                            controller: _poidsCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Poids (kg)',
                            ),
                            validator: (v) =>
                            v == null || v.isEmpty ? 'Requis' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _volumeCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Volume (m³)',
                            ),
                            validator: (v) =>
                            v == null || v.isEmpty ? 'Requis' : null,
                          ),
                        ),
                      ]),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _codeShCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Code SH',
                          hintText: 'ex: 0101.21',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                      : const Text('Créer la Fiche',
                      style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}