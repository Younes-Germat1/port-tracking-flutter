import '../core/api_client.dart';
import '../models/inspection.dart';

class InspectionService {
  static Future<List<Inspection>> getAllInspections() async {
    final response = await ApiClient.dio.get('/api/inspections');
    return (response.data as List)
        .map((json) => Inspection.fromJson(json))
        .toList();
  }

  static Future<List<Inspection>> getMesTaches(int inspecteurId) async {
    final response = await ApiClient.dio.get(
      '/api/inspections/mes-taches',
      queryParameters: {'inspecteurId': inspecteurId},
    );
    final data = response.data;
    if (data is List) {
      return data.map((json) => Inspection.fromJson(json)).toList();
    }
    return [Inspection.fromJson(data)];
  }

  static Future<Inspection> getInspectionById(int id) async {
    final response = await ApiClient.dio.get('/api/inspections/$id');
    return Inspection.fromJson(response.data);
  }

  static Future<Inspection> createInspection(
      int conteneurId,
      int inspecteurId,
      String organisme,
      ) async {
    final response = await ApiClient.dio.post(
      '/api/inspections?conteneurId=$conteneurId&inspecteurId=$inspecteurId&organisme=$organisme',
    );
    return Inspection.fromJson(response.data);
  }

  static Future<Inspection> enregistrerResultat(
      int id,
      String resultat,
      String? commentaire,
      ) async {
    final response = await ApiClient.dio.put(
      '/api/inspections/$id/resultat',
      data: {
        'resultat': resultat,
        'commentaire': commentaire ?? '',
      },
    );
    return Inspection.fromJson(response.data);
  }
}