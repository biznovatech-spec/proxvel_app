import '../../models/recommendation_result_model.dart';
import 'mock_destination_data_source.dart';

/// Fallback local de recomendaciones cuando el backend no responde.
/// Usa solo los 3 destinos de la tesis con valores aproximados
/// al ranking contextual real (Fase 4).
class MockRecommendationDataSource {
  static List<RecommendationResultModel> getRecommendations() {
    final dests = MockDestinationDataSource.activeDestinations;
    final machuPicchu = dests.firstWhere((d) => d.id == 'machu-picchu');
    final titicaca = dests.firstWhere((d) => d.id == 'lago-titicaca');
    final circuito = dests.firstWhere((d) => d.id == 'circuito-magico-del-agua');

    return [
      RecommendationResultModel(
        id: 'machu-picchu',
        destination: machuPicchu,
        compatibilityPercentage: 52.5,
        finalScore: 0.52,
        label: 'Recomendado',
        reasons: ['Alta afinidad con tu perfil', 'Clima favorable'],
        aspectScores: [],
        contextSignals: [],
      ),
      RecommendationResultModel(
        id: 'lago-titicaca',
        destination: titicaca,
        compatibilityPercentage: 51.5,
        finalScore: 0.51,
        label: 'Recomendado',
        reasons: ['Naturaleza y cultura viva', 'Aforo bajo'],
        aspectScores: [],
        contextSignals: [],
      ),
      RecommendationResultModel(
        id: 'circuito-magico-del-agua',
        destination: circuito,
        compatibilityPercentage: 49.6,
        finalScore: 0.50,
        label: 'Parcialmente recomendado',
        reasons: ['Entretenimiento accesible', 'Clima favorable'],
        aspectScores: [],
        contextSignals: [],
      ),
    ];
  }
}
