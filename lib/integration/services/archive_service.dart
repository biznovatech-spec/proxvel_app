import '../../models/archive_model.dart';
import '../api/api_client.dart';
import '../api/api_config.dart';

class ArchiveService {
  final ApiClient _apiClient;

  ArchiveService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<List<ArchiveModel>> getArchives() async {
    try {
      final response = await _apiClient.get('${ApiConfig.apiBaseUrl}/archives');
      if (response['success'] == true) {
        final List<dynamic> data = response['data'];
        return data.map((json) => ArchiveModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Error al cargar archivados: $e');
    }
  }

  Future<bool> addArchive(String destinationId) async {
    try {
      final response = await _apiClient.post('${ApiConfig.apiBaseUrl}/archives/$destinationId');
      if (response['success'] == true) {
        return response['data']['is_archived'] == true;
      }
      throw Exception(response['message'] ?? 'Error desconocido');
    } catch (e) {
      throw Exception('Error al archivar destino: $e');
    }
  }

  Future<bool> removeArchive(String destinationId) async {
    try {
      final response = await _apiClient.delete('${ApiConfig.apiBaseUrl}/archives/$destinationId');
      if (response['success'] == true) {
        return true;
      }
      throw Exception(response['message'] ?? 'Error desconocido');
    } catch (e) {
      throw Exception('Error al desarchivar destino: $e');
    }
  }

  Future<bool> checkArchive(String destinationId) async {
    try {
      final response = await _apiClient.get('${ApiConfig.apiBaseUrl}/archives/check/$destinationId');
      if (response['success'] == true) {
        return response['data']['is_archived'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
