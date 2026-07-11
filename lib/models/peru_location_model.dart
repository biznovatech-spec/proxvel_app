class PeruLocationModel {
  final String ubigeo;
  final String department;
  final String province;
  final String district;

  PeruLocationModel({
    required this.ubigeo,
    required this.department,
    required this.province,
    required this.district,
  });

  factory PeruLocationModel.fromJson(Map<String, dynamic> json) {
    return PeruLocationModel(
      ubigeo: (json['ubigeo'] ?? '').toString().trim(),
      department: (json['department'] ?? '').toString().trim().toUpperCase(),
      province: (json['province'] ?? '').toString().trim().toUpperCase(),
      district: (json['district'] ?? '').toString().trim().toUpperCase(),
    );
  }
}
