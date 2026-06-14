class TourismCatalogModel {
  final String? officialName;
  final String? department;
  final String? province;
  final String? district;
  final String? city;
  final String? region;
  final String? category;
  final String? type;
  final String? subtype;
  final String? hierarchy;
  final double? altitudeM;
  final String? description;
  final String? experienceType;
  final String? visitorInfoSummary;
  final String? activitiesSummary;
  final String? accessibilitySummary;
  final List<String> galleryImages;
  final String? officialSourceName;
  final String? officialSourceCode;
  final String? officialSourceUrl;
  final String? dataStatus;
  final double? latitude;
  final double? longitude;

  TourismCatalogModel({
    this.officialName,
    this.department,
    this.province,
    this.district,
    this.city,
    this.region,
    this.category,
    this.type,
    this.subtype,
    this.hierarchy,
    this.altitudeM,
    this.description,
    this.experienceType,
    this.visitorInfoSummary,
    this.activitiesSummary,
    this.accessibilitySummary,
    this.galleryImages = const [],
    this.officialSourceName,
    this.officialSourceCode,
    this.officialSourceUrl,
    this.dataStatus,
    this.latitude,
    this.longitude,
  });

  factory TourismCatalogModel.fromJson(Map<String, dynamic> json) {
    return TourismCatalogModel(
      officialName: json['official_name'] as String?,
      department: json['department'] as String?,
      province: json['province'] as String?,
      district: json['district'] as String?,
      city: json['city'] as String?,
      region: json['region'] as String?,
      category: json['category'] as String?,
      type: json['type'] as String?,
      subtype: json['subtype'] as String?,
      hierarchy: json['hierarchy']?.toString(),
      altitudeM: (json['altitude_m'] as num?)?.toDouble(),
      description: json['description'] as String?,
      experienceType: json['experience_type'] as String?,
      visitorInfoSummary: json['visitor_info_summary'] as String?,
      activitiesSummary: json['activities_summary'] as String?,
      accessibilitySummary: json['accessibility_summary'] as String?,
      galleryImages: (json['gallery_images'] as List<dynamic>?)
              ?.whereType<String>()
              .where((url) => url.isNotEmpty && !url.contains('wikimedia.org/wiki/File:')) // Filter out wiki page links that are not direct images
              .toList() ??
          [],
      officialSourceName: json['official_source_name'] as String?,
      officialSourceCode: json['official_source_code'] as String?,
      officialSourceUrl: json['official_source_url'] as String?,
      dataStatus: json['data_status'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }
}
