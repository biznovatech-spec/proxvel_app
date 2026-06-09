import '../../models/recommendation_result_model.dart';
import 'mock_destination_data_source.dart';

class MockRecommendationDataSource {
  static List<RecommendationResultModel> getRecommendations() {
    final dests = MockDestinationDataSource.destinations;
    return [
      RecommendationResultModel(
        id: 'rec1',
        destination: dests[0], // Machu Picchu
        compatibilityPercentage: 95.0,
        finalScore: 4.8,
        label: 'Recomendado',
        reasons: ['Ideal para tu presupuesto', 'Clima perfecto para ti'],
        aspectScores: [],
        contextSignals: [],
      ),
      RecommendationResultModel(
        id: 'rec2',
        destination: dests[3], // Laguna 69
        compatibilityPercentage: 88.0,
        finalScore: 4.5,
        label: 'Recomendado',
        reasons: ['Aventura en naturaleza', 'Paisajes únicos'],
        aspectScores: [],
        contextSignals: [],
      ),
      RecommendationResultModel(
        id: 'rec3',
        destination: dests[6], // Valle Sagrado
        compatibilityPercentage: 82.0,
        finalScore: 4.3,
        label: 'Parcialmente recomendado',
        reasons: ['Riqueza cultural', 'Gastronomía local excelente'],
        aspectScores: [],
        contextSignals: [],
      ),
      RecommendationResultModel(
        id: 'rec4',
        destination: dests[1], // Huacachina
        compatibilityPercentage: 78.0,
        finalScore: 4.1,
        label: 'Parcialmente recomendado',
        reasons: ['Experiencia única en dunas', 'Clima cálido favorable'],
        aspectScores: [],
        contextSignals: [],
      ),
      RecommendationResultModel(
        id: 'rec5',
        destination: dests[4], // Río Amazonas
        compatibilityPercentage: 72.0,
        finalScore: 3.9,
        label: 'Parcialmente recomendado',
        reasons: ['Biodiversidad excepcional', 'Aventura en selva'],
        aspectScores: [],
        contextSignals: [],
      ),
    ];
  }
}
