import '../../models/destination_model.dart';
import '../../models/aspect_score_model.dart';
import '../mock/mock_destination_data_source.dart';
import '../mock/mock_aspect_data_source.dart';

class DestinationService {
  Future<List<DestinationModel>> getDestinations() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return MockDestinationDataSource.destinations;
  }

  Future<List<DestinationModel>> getRecentSearches() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return MockDestinationDataSource.recentSearches;
  }

  /// Returns mock aspect scores for a destination.
  Future<List<AspectScoreModel>> getAspectScores(String destinationId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return MockAspectDataSource.getAspectScores(destinationId);
  }

  /// Returns a mock recommendation explanation.
  Future<String> getExplanation(String destinationId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return MockAspectDataSource.getExplanation(destinationId);
  }

  /// Returns mock compatibility percentage.
  Future<int> getCompatibility(String destinationId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return MockAspectDataSource.getCompatibility(destinationId);
  }
}
