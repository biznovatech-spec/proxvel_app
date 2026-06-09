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

  // ── Extended fields for "Sobre el destino" ──
  final String? type;           // e.g. 'Sitios Arqueológicos', 'Parque Nacional'
  final String? hierarchy;      // e.g. 'Jerarquía 4', 'Jerarquía 3'
  final double? altitudeM;      // Altitude in meters
  final String? bestSeason;     // e.g. 'Abril - Octubre'
  final List<String> activities;  // e.g. ['Caminata', 'Fotografía', ...]
  final List<String> galleryImages; // Additional image asset paths

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
    this.type,
    this.hierarchy,
    this.altitudeM,
    this.bestSeason,
    this.activities = const [],
    this.galleryImages = const [],
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
        type: json['type'],
        hierarchy: json['hierarchy'],
        altitudeM: json['altitudeM']?.toDouble(),
        bestSeason: json['bestSeason'],
        activities: List<String>.from(json['activities'] ?? []),
        galleryImages: List<String>.from(json['galleryImages'] ?? []),
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
        'type': type,
        'hierarchy': hierarchy,
        'altitudeM': altitudeM,
        'bestSeason': bestSeason,
        'activities': activities,
        'galleryImages': galleryImages,
      };
}
