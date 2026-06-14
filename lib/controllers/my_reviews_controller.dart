import 'package:flutter/material.dart';
import '../models/review_model.dart';
import '../models/user_model.dart';
import '../integration/services/review_service.dart';

class MyReviewsController extends ChangeNotifier {
  final ReviewService _reviewService;

  bool isLoading = false;
  List<ReviewModel> reviews = [];
  String? error;

  MyReviewsController(this._reviewService);

  Future<void> loadUserReviews(UserModel? currentUser) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      // Regla: Usar el usuario actual si es válido y proviene del backend (ej. U00001).
      // Los usuarios creados localmente tienen un ID puramente numérico (timestamp).
      // Si el usuario es local o nulo, forzamos U00001 como fallback MVP.
      bool isBackendUser = currentUser?.id != null && currentUser!.id.startsWith('U');
      String userId = isBackendUser ? currentUser.id : 'U00001';

      reviews = await _reviewService.getReviewsByUser(userId);
    } catch (e) {
      error = 'No se pudieron cargar tus reseñas. Inténtalo nuevamente.';
      debugPrint('[MyReviewsController] Error: $e');
    }

    isLoading = false;
    notifyListeners();
  }
}
