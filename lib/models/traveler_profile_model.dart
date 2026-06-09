class TravelerProfileModel {
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
