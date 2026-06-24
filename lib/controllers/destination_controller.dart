import 'package:flutter/material.dart';
import '../models/destination_model.dart';
import '../models/aspect_score_model.dart';
import '../models/tourism_catalog_model.dart';
import '../models/review_model.dart';
import '../integration/services/destination_service.dart';
import '../integration/services/tourism_service.dart';
import '../integration/services/review_service.dart';

class DestinationController extends ChangeNotifier {
  final DestinationService _destinationService;
  final TourismService _tourismService;
  final ReviewService _reviewService;

  bool isLoading = false;
  DestinationModel? destination;
  TourismCatalogModel? tourismInfo;
  List<ReviewModel> reviews = [];
  double averageRating = 0.0;
  bool hasReviewsError = false;

  List<AspectScoreModel> aspectScores = [];
  String explanation = '';
  int compatibility = 0;
  String? error;

  // Contexto REAL del mes (clima + aforo), NO de reseñas. score 0-1, alto = mejor.
  double? climaContextScore;
  String? climaContextLabel;
  double? aforoContextScore;
  String? aforoContextLabel;
  String? contextMonthName;

  DestinationController(this._destinationService, this._tourismService, this._reviewService);

  Future<void> loadDestination(String id, {int? month}) async {
    isLoading = true;
    error = null;
    hasReviewsError = false;
    notifyListeners();
    try {
      destination = await _destinationService.getDestinationById(id, month: month);
      if (destination == null) {
        throw Exception('Destino no encontrado: $id');
      }

      // Load supplementary detail data in parallel (mismo mes para todo)
      final results = await Future.wait([
        _destinationService.getAspectScores(id, month: month),
        _destinationService.getExplanation(id, month: month),
        _destinationService.getCompatibility(id, month: month),
        _destinationService.getDestinationContext(id, month: month),
      ]);
      aspectScores = results[0] as List<AspectScoreModel>;
      explanation = results[1] as String;
      compatibility = results[2] as int;

      final ctx = results[3] as Map<String, dynamic>;
      climaContextScore = ctx['clima_score'] as double?;
      climaContextLabel = ctx['clima_label'] as String?;
      aforoContextScore = ctx['aforo_score'] as double?;
      aforoContextLabel = ctx['aforo_label'] as String?;
      contextMonthName = ctx['month_name'] as String?;

      // Load tourism catalog and reviews (they shouldn't block the basic rendering if they fail, but we wait for them)
      try {
        tourismInfo = await _tourismService.getTourismCatalog(id);
      } catch (e) {
        debugPrint('Error loading tourism catalog: $e');
        tourismInfo = null;
      }

      try {
        reviews = await _reviewService.getReviewsForDestination(id);
        if (reviews.isNotEmpty) {
          final total = reviews.fold(0.0, (sum, item) => sum + item.ratingGeneral);
          averageRating = total / reviews.length;
        } else {
          averageRating = 0.0;
        }
      } catch (e) {
        debugPrint('Error loading reviews: $e');
        reviews = [];
        averageRating = 0.0;
        hasReviewsError = true;
      }

    } catch (e) {
      error = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }
}
