import 'package:flutter/material.dart';
import '../models/fiche.dart';
import '../services/fiche_service.dart';

class FicheProvider extends ChangeNotifier {
  List<Fiche> _fiches = [];
  bool _loading = false;
  String? _error;

  List<Fiche> get fiches => _fiches;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> loadFiches({String? role, int? userId}) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final all = await FicheService.getAllFiches();
      if (role == 'IMPORTATEUR' && userId != null) {
        _fiches = all.where((f) => f.importateurId == userId).toList();
      } else if (role == 'OPERATEUR') {
        _fiches = all.where((f) =>
            ['APPROUVEE', 'PLACEE'].contains(f.statut)).toList();
      } else {
        _fiches = all;
      }
    } catch (e) {
      _error = 'Erreur lors du chargement des fiches';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> updateStatut(int id, String statut, int acteurId) async {
    await FicheService.updateStatut(id, statut, acteurId);
    await loadFiches();
  }

  List<Fiche> filterByStatut(String statut) =>
      _fiches.where((f) => f.statut == statut).toList();

  int countByStatut(String statut) =>
      _fiches.where((f) => f.statut == statut).length;
}