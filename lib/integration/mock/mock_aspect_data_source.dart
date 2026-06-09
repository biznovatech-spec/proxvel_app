import '../../models/aspect_score_model.dart';

/// Mock aspect scores for destination detail views.
class MockAspectDataSource {
  /// Returns simulated aspect scores for a given destination.
  static List<AspectScoreModel> getAspectScores(String destinationId) {
    // Vary scores per destination using id hash for diversity
    final seed = destinationId.hashCode.abs() % 10;
    return [
      AspectScoreModel(aspect: 'Atractivos turísticos', score: _clamp(0.75 + seed * 0.02)),
      AspectScoreModel(aspect: 'Costos', score: _clamp(0.60 + seed * 0.03)),
      AspectScoreModel(aspect: 'Seguridad', score: _clamp(0.80 - seed * 0.01)),
      AspectScoreModel(aspect: 'Accesibilidad', score: _clamp(0.55 + seed * 0.04)),
      AspectScoreModel(aspect: 'Limpieza', score: _clamp(0.70 + seed * 0.02)),
      AspectScoreModel(aspect: 'Atención y servicio', score: _clamp(0.65 + seed * 0.03)),
      AspectScoreModel(aspect: 'Gastronomía', score: _clamp(0.72 + seed * 0.01)),
      AspectScoreModel(aspect: 'Alojamiento', score: _clamp(0.58 + seed * 0.04)),
      AspectScoreModel(aspect: 'Clima', score: _clamp(0.82 - seed * 0.02)),
      AspectScoreModel(aspect: 'Aforo / multitudes', score: _clamp(0.50 + seed * 0.05)),
    ];
  }

  /// Returns a mock explanation string for the destination recommendation.
  static String getExplanation(String destinationId) {
    final explanations = [
      'Este destino se recomienda porque coincide con tu preferencia de clima templado, tu presupuesto medio y tu interés en experiencias culturales. Los aspectos de seguridad y atractivos turísticos superan el promedio regional.',
      'La puntuación alta en naturaleza y aventura se alinea con tus intereses. El costo se encuentra dentro de tu rango presupuestario y las condiciones climáticas son favorables para la época seleccionada.',
      'Destino recomendado por su alta compatibilidad con tus preferencias de viaje. Los indicadores de gastronomía y cultura son sobresalientes, y la accesibilidad facilita la visita en el tiempo disponible.',
      'Este lugar destaca en atractivos turísticos y paisajes naturales. Tu perfil de viajero indica una preferencia por destinos con bajo nivel de multitudes, lo cual coincide con este destino.',
      'La combinación de clima favorable, costos accesibles y alta calificación en seguridad hace que este destino sea altamente compatible con tu perfil de viajero.',
    ];
    final idx = destinationId.hashCode.abs() % explanations.length;
    return explanations[idx];
  }

  /// Returns a mock compatibility percentage for a destination.
  static int getCompatibility(String destinationId) {
    final base = 65 + (destinationId.hashCode.abs() % 30);
    return base.clamp(60, 98);
  }

  static double _clamp(double v) => v.clamp(0.0, 1.0);
}
