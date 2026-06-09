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
      recommendations = await _recommendationService.getRecommendations();
    } catch (e) {
      error = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }
}
