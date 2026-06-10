import 'package:flutter/material.dart';
import '../models/destination_model.dart';
import '../models/aspect_score_model.dart';
import '../integration/services/destination_service.dart';

class DestinationController extends ChangeNotifier {
  final DestinationService _destinationService;
  bool isLoading = false;
  DestinationModel? destination;
  List<AspectScoreModel> aspectScores = [];
  String explanation = '';
  int compatibility = 0;
  String? error;

  DestinationController(this._destinationService);

  Future<void> loadDestination(String id) async {
    isLoading = true;
    error = null;
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
    } catch (e) {
      error = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }
}
