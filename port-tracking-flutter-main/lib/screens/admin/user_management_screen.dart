import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/user.dart';
import '../../services/user_service.dart';
import '../../widgets/app_drawer.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  List<User> _users = [];
  bool _loading = true;

  final _nomCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  String _role = 'IMPORTATEUR';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _users = await UserService.getAllUsers();
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showCreateModal() {
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
            const Text('Créer Utilisateur',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(controller: _nomCtrl,
                decoration: const InputDecoration(labelText: 'Nom')),
            const SizedBox(height: 10),
            TextField(controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 10),
            TextField(controller: _passwordCtrl, obscureText: true,
                decoration: const InputDecoration(labelText: 'Mot de passe')),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _role,
              decoration: const InputDecoration(labelText: 'Rôle'),
              items: ['IMPORTATEUR', 'ADII', 'OPERATEUR', 'INSPECTEUR', 'ADMIN']
                  .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                  .toList(),
              onChanged: (v) => setState(() => _role = v ?? 'IMPORTATEUR'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await UserService.createUser(
                    _nomCtrl.text, _emailCtrl.text,
                    _passwordCtrl.text, _role);
                Navigator.of(modalContext).pop();
                _nomCtrl.clear();
                _emailCtrl.clear();
                _passwordCtrl.clear();
                await _load();
              },
              child: const Text('Créer'),
            ),
          ],
        ),
      ),
    );
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'ADMIN': return const Color(0xFFDC2626);
      case 'IMPORTATEUR': return const Color(0xFF2563EB);
      case 'ADII': return const Color(0xFF16A34A);
      case 'OPERATEUR': return const Color(0xFFD97706);
      case 'INSPECTEUR': return const Color(0xFF7C3AED);
      default: return const Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text('Utilisateurs',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      drawer: const AppDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateModal,
        icon: const Icon(Icons.person_add_outlined),
        label: const Text('Nouvel Utilisateur'),
        backgroundColor: const Color(0xFF2563EB),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _load,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _users.length,
          itemBuilder: (_, i) {
            final u = _users[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _roleColor(u.role).withOpacity(0.15),
                  child: Text(
                    u.nom[0].toUpperCase(),
                    style: TextStyle(
                        color: _roleColor(u.role),
                        fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(u.nom,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(u.email,
                    style: const TextStyle(fontSize: 12)),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _roleColor(u.role).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(u.role,
                      style: TextStyle(
                          color: _roleColor(u.role),
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}