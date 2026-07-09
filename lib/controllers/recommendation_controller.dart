import 'package:flutter/material.dart';
import '../models/recommendation_result_model.dart';
import '../integration/services/recommendation_service.dart';
import '../integration/api/api_client.dart';

class RecommendationController extends ChangeNotifier {
  final RecommendationService _recommendationService;
  bool isLoading = false;
  List<RecommendationResultModel> recommendations = [];
  String? error;

  /// Mes objetivo (1-12). null = mes actual (lo decide el backend).
  int? selectedMonth;
  /// Departamento/región para filtrar. null = todos.
  String? selectedRegion;

  /// true si los datos en memoria ya no son válidos (perfil cambió).
  bool _isStale = false;

  RecommendationController(this._recommendationService);

  /// Marca las recomendaciones actuales como inválidas.
  /// No borra los datos inmediatamente (para evitar flash vacío),
  /// pero la próxima llamada a loadRecommendations sabrá que debe recargar.
  void invalidate() {
    _isStale = true;
    // IMPORTANTE: No borramos 'recommendations' aquí para evitar flash vacío.
    // La UI mostrará el estado de "refreshing" usando los datos existentes.
    error = null;
    notifyListeners();
  }

  /// Cambia el mes objetivo y recarga las recomendaciones.
  Future<void> setMonth(int? month) async {
    if (selectedMonth == month) return;
    selectedMonth = month;
    await loadRecommendations(forceRefresh: true);
  }

  /// Cambia el filtro de departamento y recarga.
  Future<void> setRegion(String? region) async {
    if (selectedRegion == region) return;
    selectedRegion = region;
    await loadRecommendations(forceRefresh: true);
  }

  Future<void> loadRecommendations({bool forceRefresh = false}) async {
    // Guard: evitar requests simultáneos.
    if (isLoading) return;

    // Si ya hay datos y no es forzado ni stale, no recargar.
    if (!forceRefresh && !_isStale && recommendations.isNotEmpty) return;

    isLoading = true;
    error = null;
    notifyListeners();
    
    final startTime = DateTime.now();
    try {
      // Usamos el motor real para el usuario autenticado
      final newRecs = await _recommendationService.getMyRecommendations(
        month: selectedMonth,
        region: selectedRegion,
      );
      recommendations = newRecs;
      _isStale = false;
    } catch (e) {
      if (e is ApiException) {
        error = e.message;
      } else {
        error = e.toString().replaceAll('Exception: ', '');
      }
    }

    // Duración mínima visual para evitar parpadeos bruscos
    final elapsed = DateTime.now().difference(startTime);
    if (elapsed.inMilliseconds < 1000) {
      await Future.delayed(Duration(milliseconds: 1000 - elapsed.inMilliseconds));
    }

    isLoading = false;
    notifyListeners();
  }

  /// Limpia todo el estado en memoria. Llamar al logout/cambio de usuario.
  void clearState() {
    recommendations = [];
    error = null;
    _isStale = false;
    isLoading = false;
    selectedMonth = null;
    selectedRegion = null;
    notifyListeners();
  }
}
