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
      if (currentUser == null) {
        error = 'No se encontró un usuario activo. Regístrate o inicia sesión para continuar.';
        reviews = [];
        isLoading = false;
        notifyListeners();
        return;
      }
      
      String userId = currentUser.id;

      reviews = await _reviewService.getReviewsByUser(userId);
    } catch (e) {
      error = 'No se pudieron cargar tus reseñas. Inténtalo nuevamente.';
      debugPrint('[MyReviewsController] Error: $e');
    }

    isLoading = false;
    notifyListeners();
  }
}
