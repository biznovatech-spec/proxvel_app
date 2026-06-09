class DestinationModel {
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
  final double? distanceKm;
  final String? estimatedDays;
  final bool isTrending;

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
    this.distanceKm,
    this.estimatedDays,
    this.isTrending = false,
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
        distanceKm: json['distanceKm']?.toDouble(),
        estimatedDays: json['estimatedDays'],
        isTrending: json['isTrending'] ?? false,
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
        'distanceKm': distanceKm,
        'estimatedDays': estimatedDays,
        'isTrending': isTrending,
      };
}
