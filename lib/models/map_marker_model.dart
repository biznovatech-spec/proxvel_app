class MapMarkerModel {
  final String destinationId;
  final String destination;
  final double latitude;
  final double longitude;
  final String? category;
  final String? label;

  // Campos adicionales que podrían agregarse en el futuro
  final String? city;
  final String? region;
  final String? coverImageUrl;
  final double? rating;

  MapMarkerModel({
    required this.destinationId,
    required this.destination,
    required this.latitude,
    required this.longitude,
    this.category,
    this.label,
    this.city,
    this.region,
    this.coverImageUrl,
    this.rating,
  });

  factory MapMarkerModel.fromJson(Map<String, dynamic> json) {
    return MapMarkerModel(
      destinationId: json['destination_id'] as String? ?? '',
      destination: json['destination'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      category: json['category'] as String?,
      label: json['label'] as String?,
      city: json['city'] as String?,
      region: json['region'] as String?,
      coverImageUrl: json['cover_image_url'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'destination_id': destinationId,
      'destination': destination,
      'latitude': latitude,
      'longitude': longitude,
      'category': category,
      'label': label,
      'city': city,
      'region': region,
      'cover_image_url': coverImageUrl,
      'rating': rating,
    };
  }
}
