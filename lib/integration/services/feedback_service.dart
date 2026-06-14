import 'package:flutter/foundation.dart';
import '../../models/feedback_model.dart';
import '../local/local_storage_service.dart';
import '../api/api_client.dart';

class FeedbackService {
  final ApiClient? _api;

  FeedbackService(LocalStorageService storage, {ApiClient? apiClient}) : _api = apiClient;

  Future<void> submitFeedback(FeedbackModel feedback) async {
    if (_api != null) {
      try {
        await _api.post('/reviews', feedback.toApiJson());
        // Ya no guardamos localmente por solicitud del usuario (fuente de verdad = backend)
      } catch (e) {
        debugPrint('[FeedbackService] Falló el envío de feedback: $e');
        throw Exception('No se pudo enviar la reseña. Verifica tu conexión.');
      }
    } else {
      throw Exception('ApiClient no configurado en FeedbackService');
    }
  }
}
