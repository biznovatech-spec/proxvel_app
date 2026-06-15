class FavoriteModel {
  final String destinationId;
  final String name;
  final String? city;
  final String? region;
  final String? category;
  final String? coverImageUrl;
  final double? rating;
  final bool isFavorite;
  final DateTime? createdAt;

  FavoriteModel({
    required this.destinationId,
    required this.name,
    this.city,
    this.region,
    this.category,
    this.coverImageUrl,
    this.rating,
    this.isFavorite = true,
    this.createdAt,
  });

  factory FavoriteModel.fromJson(Map<String, dynamic> json) {
    return FavoriteModel(
      destinationId: json['destination_id'] ?? '',
      name: json['name'] ?? '',
      city: json['city'],
      region: json['region'],
      category: json['category'],
      coverImageUrl: json['cover_image_url'],
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      isFavorite: json['is_favorite'] ?? true,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'destination_id': destinationId,
      'name': name,
      'city': city,
      'region': region,
      'category': category,
      'cover_image_url': coverImageUrl,
      'rating': rating,
      'is_favorite': isFavorite,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
