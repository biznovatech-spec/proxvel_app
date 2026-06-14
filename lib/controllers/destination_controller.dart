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

  DestinationController(this._destinationService, this._tourismService, this._reviewService);

  Future<void> loadDestination(String id) async {
    isLoading = true;
    error = null;
    hasReviewsError = false;
    notifyListeners();
    try {
      destination = await _destinationService.getDestinationById(id);
      if (destination == null) {
        throw Exception('Destino no encontrado: $id');
      }

      // Load supplementary detail data in parallel
      final results = await Future.wait([
        _destinationService.getAspectScores(id),
        _destinationService.getExplanation(id),
        _destinationService.getCompatibility(id),
      ]);
      aspectScores = results[0] as List<AspectScoreModel>;
      explanation = results[1] as String;
      compatibility = results[2] as int;

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
