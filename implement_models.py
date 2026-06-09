import os

base_dir = r"c:\Users\danie\Documents\Proyectos\proxvell_app\lib\models"

files = {
    "user_model.dart": """class UserModel {
  final String id;
  final String name;
  final String email;

  UserModel({required this.id, required this.name, required this.email});

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'],
        name: json['name'],
        email: json['email'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
      };
}
""",
    "traveler_profile_model.dart": """class TravelerProfileModel {
  final String budget;
  final String preferredClimate;
  final String crowdTolerance;
  final List<String> interests;
  final String accessibility;
  final String experienceType;

  TravelerProfileModel({
    required this.budget,
    required this.preferredClimate,
    required this.crowdTolerance,
    required this.interests,
    required this.accessibility,
    required this.experienceType,
  });

  factory TravelerProfileModel.fromJson(Map<String, dynamic> json) => TravelerProfileModel(
        budget: json['budget'],
        preferredClimate: json['preferredClimate'],
        crowdTolerance: json['crowdTolerance'],
        interests: List<String>.from(json['interests'] ?? []),
        accessibility: json['accessibility'],
        experienceType: json['experienceType'],
      );

  Map<String, dynamic> toJson() => {
        'budget': budget,
        'preferredClimate': preferredClimate,
        'crowdTolerance': crowdTolerance,
        'interests': interests,
        'accessibility': accessibility,
        'experienceType': experienceType,
      };
}
""",
    "feedback_model.dart": """class FeedbackModel {
  final String userId;
  final String destinationId;
  final double rating;
  final String comment;
  final String interactionType;

  FeedbackModel({
    required this.userId,
    required this.destinationId,
    required this.rating,
    required this.comment,
    required this.interactionType,
  });

  factory FeedbackModel.fromJson(Map<String, dynamic> json) => FeedbackModel(
        userId: json['userId'],
        destinationId: json['destinationId'],
        rating: json['rating'].toDouble(),
        comment: json['comment'],
        interactionType: json['interactionType'],
      );

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'destinationId': destinationId,
        'rating': rating,
        'comment': comment,
        'interactionType': interactionType,
      };
}
""",
    "context_signal_model.dart": """class ContextSignalModel {
  final String type; // e.g. 'climate', 'crowdLevel'
  final String value;
  final double weight;

  ContextSignalModel({required this.type, required this.value, required this.weight});

  factory ContextSignalModel.fromJson(Map<String, dynamic> json) => ContextSignalModel(
        type: json['type'],
        value: json['value'],
        weight: json['weight'].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'type': type,
        'value': value,
        'weight': weight,
      };
}
""",
    "route_model.dart": """class RouteModel {
  final String id;
  final String name;
  final String description;
  final List<String> destinationIds;
  final int estimatedDurationMinutes;

  RouteModel({
    required this.id,
    required this.name,
    required this.description,
    required this.destinationIds,
    required this.estimatedDurationMinutes,
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) => RouteModel(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        destinationIds: List<String>.from(json['destinationIds'] ?? []),
        estimatedDurationMinutes: json['estimatedDurationMinutes'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'destinationIds': destinationIds,
        'estimatedDurationMinutes': estimatedDurationMinutes,
      };
}
""",
    "destination_model.dart": """class DestinationModel {
  final String id;
  final String name;
  final String city;
  final String region;
  final String category;
  final String description;
  final String imageUrl;
  final double averageCost;
  final String climate;
  final String crowdLevel;
  final double rating;
  final List<String> aspects;

  DestinationModel({
    required this.id,
    required this.name,
    required this.city,
    required this.region,
    required this.category,
    required this.description,
    required this.imageUrl,
    required this.averageCost,
    required this.climate,
    required this.crowdLevel,
    required this.rating,
    required this.aspects,
  });

  factory DestinationModel.fromJson(Map<String, dynamic> json) => DestinationModel(
        id: json['id'],
        name: json['name'],
        city: json['city'],
        region: json['region'],
        category: json['category'],
        description: json['description'],
        imageUrl: json['imageUrl'],
        averageCost: json['averageCost'].toDouble(),
        climate: json['climate'],
        crowdLevel: json['crowdLevel'],
        rating: json['rating'].toDouble(),
        aspects: List<String>.from(json['aspects'] ?? []),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'city': city,
        'region': region,
        'category': category,
        'description': description,
        'imageUrl': imageUrl,
        'averageCost': averageCost,
        'climate': climate,
        'crowdLevel': crowdLevel,
        'rating': rating,
        'aspects': aspects,
      };
}
""",
    "recommendation_result_model.dart": """import 'destination_model.dart';
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
""",
    "aspect_score_model.dart": """class AspectScoreModel {
  final String aspect;
  final double score;

  AspectScoreModel({required this.aspect, required this.score});

  factory AspectScoreModel.fromJson(Map<String, dynamic> json) => AspectScoreModel(
        aspect: json['aspect'],
        score: json['score'].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'aspect': aspect,
        'score': score,
      };
}
"""
}

for rel_path, content in files.items():
    with open(os.path.join(base_dir, rel_path), "w", encoding="utf-8") as f:
        f.write(content)

print("Modelos base implementados.")
