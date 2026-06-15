import '../core/api_client.dart';
import '../models/fiche.dart';

class FicheService {
  static Future<List<Fiche>> getAllFiches() async {
    final response = await ApiClient.dio.get('/api/fiches');
    return (response.data as List)
        .map((json) => Fiche.fromJson(json))
        .toList();
  }

  static Future<Fiche> getFicheById(int id) async {
    final response = await ApiClient.dio.get('/api/fiches/$id');
    return Fiche.fromJson(response.data);
  }

  static Future<Fiche> createFiche(Map<String, dynamic> data) async {
    final response = await ApiClient.dio.post('/api/fiches', data: data);
    return Fiche.fromJson(response.data);
  }

  static Future<Fiche> updateStatut(int id, String statut, int acteurId) async {
    final response = await ApiClient.dio.put(
      '/api/fiches/$id/statut?acteurId=$acteurId',
      data: {'statut': statut},
    );
    return Fiche.fromJson(response.data);
  }

  static Future<List<dynamic>> getHistorique(int id) async {
    final response = await ApiClient.dio.get('/api/fiches/$id/historique');
    return response.data as List;
  }
}