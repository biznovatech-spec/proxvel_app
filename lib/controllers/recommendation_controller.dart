import 'package:flutter/material.dart';
import '../models/recommendation_result_model.dart';
import '../integration/services/recommendation_service.dart';

class RecommendationController extends ChangeNotifier {
  final RecommendationService _recommendationService;
  bool isLoading = false;
  List<RecommendationResultModel> recommendations = [];
  String? error;

  RecommendationController(this._recommendationService);

  Future<void> loadRecommendations() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      // Usamos el motor real para el usuario autenticado
      recommendations = await _recommendationService.getMyRecommendations();
    } catch (e) {
      if (e.toString().contains('400')) {
        error = 'Completa tu perfil viajero para recibir recomendaciones personalizadas.';
      } else {
        // Limpiamos mensajes como "Exception: "
        error = e.toString().replaceAll('Exception: ', '');
      }
    }
    isLoading = false;
    notifyListeners();
  }
}
