import 'package:flutter/material.dart';
import '../models/recommendation_result_model.dart';
import '../integration/services/recommendation_service.dart';

class RecommendationController extends ChangeNotifier {
  final RecommendationService _recommendationService;
  bool isLoading = false;
  List<RecommendationResultModel> recommendations = [];
  String? error;

  /// Mes objetivo (1-12). null = mes actual (lo decide el backend).
  int? selectedMonth;
  /// Departamento/región para filtrar. null = todos.
  String? selectedRegion;

  RecommendationController(this._recommendationService);

  /// Cambia el mes objetivo y recarga las recomendaciones.
  Future<void> setMonth(int? month) async {
    if (selectedMonth == month) return;
    selectedMonth = month;
    await loadRecommendations();
  }

  /// Cambia el filtro de departamento y recarga.
  Future<void> setRegion(String? region) async {
    if (selectedRegion == region) return;
    selectedRegion = region;
    await loadRecommendations();
  }

  Future<void> loadRecommendations() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      // Usamos el motor real para el usuario autenticado
      recommendations = await _recommendationService.getMyRecommendations(
        month: selectedMonth,
        region: selectedRegion,
      );
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
