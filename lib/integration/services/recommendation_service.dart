import '../../models/recommendation_result_model.dart';
import '../mock/mock_recommendation_data_source.dart';

class RecommendationService {
  Future<List<RecommendationResultModel>> getRecommendations() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return MockRecommendationDataSource.getRecommendations();
  }
}
