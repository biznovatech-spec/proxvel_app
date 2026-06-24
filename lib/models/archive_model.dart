class ArchiveModel {
  final String destinationId;
  final String name;
  final String? city;
  final String? region;
  final String? category;
  final String? coverImageUrl;
  final bool isArchived;
  final DateTime? createdAt;

  ArchiveModel({
    required this.destinationId,
    required this.name,
    this.city,
    this.region,
    this.category,
    this.coverImageUrl,
    this.isArchived = true,
    this.createdAt,
  });

  factory ArchiveModel.fromJson(Map<String, dynamic> json) {
    return ArchiveModel(
      destinationId: json['destination_id'] ?? '',
      name: json['name'] ?? '',
      city: json['city'],
      region: json['region'],
      category: json['category'],
      coverImageUrl: json['cover_image_url'],
      isArchived: json['is_archived'] ?? true,
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
      'is_archived': isArchived,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
