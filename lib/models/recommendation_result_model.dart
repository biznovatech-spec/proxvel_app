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
