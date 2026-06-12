import 'destination_model.dart';
import 'aspect_score_model.dart';
import 'context_signal_model.dart';

class RecommendationResultModel {
  final String id;
  final DestinationModel destination;
  final double compatibilityPercentage;
  final double finalScore;
  final String label; // Recomendado, Parcialmente recomendado, No recomendado
  final List<String> reasons;
  final List<AspectScoreModel> aspectScores;
  final List<ContextSignalModel> contextSignals;

  RecommendationResultModel({
    required this.id,
    required this.destination,
    required this.compatibilityPercentage,
    required this.finalScore,
    required this.label,
    required this.reasons,
    required this.aspectScores,
    required this.contextSignals,
  });

  /// Construye un resultado desde un item del ranking contextual del backend
  /// (GET /recommendations/contextual). El backend V2 no envía etiqueta,
  /// así que se deriva del porcentaje de compatibilidad contextual.
  factory RecommendationResultModel.fromApiJson(Map<String, dynamic> json) {
    final compat = (json['compatibility_percentage'] as num?)?.toDouble() ?? 0.0;
    final context = json['context'] as Map<String, dynamic>? ?? {};

    String label = json['label'] ??
        (compat >= 55
            ? 'Recomendado'
            : compat >= 45
                ? 'Parcialmente recomendado'
                : 'No recomendado');

    final reasons = <String>[];
    final contextReason = context['context_reason'];
    if (contextReason is String && contextReason.isNotEmpty) {
      reasons.add(contextReason);
    }
    final explanation = json['short_explanation'];
    if (explanation is String && explanation.isNotEmpty) {
      reasons.add(explanation);
    }

    final signals = <ContextSignalModel>[];
    final weatherCat = context['weather_category'];
    final weatherScore = (context['weather_score'] as num?)?.toDouble();
    if (weatherCat is String && weatherCat.isNotEmpty) {
      signals.add(ContextSignalModel(
        type: 'climate',
        value: weatherCat,
        weight: weatherScore ?? 0.0,
      ));
    }
    final crowdLevel = context['crowd_level'];
    final crowdScore = (context['crowd_score'] as num?)?.toDouble();
    if (crowdLevel is String && crowdLevel.isNotEmpty) {
      signals.add(ContextSignalModel(
        type: 'crowdLevel',
        value: crowdLevel,
        weight: crowdScore ?? 0.0,
      ));
    }

    final aspects = <AspectScoreModel>[];
    final aspectMap = json['aspect_scores'] as Map<String, dynamic>?;
    if (aspectMap != null) {
      aspectMap.forEach((key, value) {
        if (value is num) {
          aspects.add(AspectScoreModel(aspect: key, score: value.toDouble()));
        }
      });
    }

    return RecommendationResultModel(
      id: json['destination_id'] ?? '',
      destination: DestinationModel.fromApiRecommendation(json),
      compatibilityPercentage: compat,
      finalScore: (json['final_score'] as num?)?.toDouble() ?? 0.0,
      label: label,
      reasons: reasons,
      aspectScores: aspects,
      contextSignals: signals,
    );
  }

  factory RecommendationResultModel.fromJson(Map<String, dynamic> json) => RecommendationResultModel(
        id: json['id'],
        destination: DestinationModel.fromJson(json['destination']),
        compatibilityPercentage: json['compatibilityPercentage'].toDouble(),
        finalScore: json['finalScore'].toDouble(),
        label: json['label'],
        reasons: List<String>.from(json['reasons'] ?? []),
        aspectScores: (json['aspectScores'] as List).map((i) => AspectScoreModel.fromJson(i)).toList(),
        contextSignals: (json['contextSignals'] as List).map((i) => ContextSignalModel.fromJson(i)).toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'destination': destination.toJson(),
        'compatibilityPercentage': compatibilityPercentage,
        'finalScore': finalScore,
        'label': label,
        'reasons': reasons,
        'aspectScores': aspectScores.map((i) => i.toJson()).toList(),
        'contextSignals': contextSignals.map((i) => i.toJson()).toList(),
      };
}
