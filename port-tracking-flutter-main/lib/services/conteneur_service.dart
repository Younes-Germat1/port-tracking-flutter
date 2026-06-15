import '../core/api_client.dart';
import '../models/conteneur.dart';

class ConteneurService {
  static Future<List<Conteneur>> getConteneursByFiche(int ficheId) async {
    final response = await ApiClient.dio.get('/api/conteneurs/fiche/$ficheId');
    return (response.data as List)
        .map((json) => Conteneur.fromJson(json))
        .toList();
  }

  static Future<Conteneur> getConteneurById(int id) async {
    final response = await ApiClient.dio.get('/api/conteneurs/$id');
    return Conteneur.fromJson(response.data);
  }

  static Future<Conteneur> createConteneur(int ficheId) async {
    final response = await ApiClient.dio.post(
      '/api/conteneurs?ficheId=$ficheId',
    );
    return Conteneur.fromJson(response.data);
  }

  static Future<Conteneur> assignEmplacement(
      int id,
      String zone,
      String rangee,
      String position,
      String quai,
      ) async {
    final response = await ApiClient.dio.put(
      '/api/conteneurs/$id/emplacement',
      data: {
        'zone': zone,
        'rangee': rangee,
        'position': position,
        'quai': quai,
      },
    );
    return Conteneur.fromJson(response.data);
  }

  static Future<int> getDwellTime(int id) async {
    final response = await ApiClient.dio.get('/api/conteneurs/$id/dwell-time');
    return response.data as int;
  }
}