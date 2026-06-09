class RouteModel {
  final String id;
  final String name;
  final String description;
  final List<String> destinationIds;
  final int estimatedDurationMinutes;
  final bool isCompleted;

  RouteModel({
    required this.id,
    required this.name,
    required this.description,
    required this.destinationIds,
    required this.estimatedDurationMinutes,
    this.isCompleted = false,
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) => RouteModel(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        destinationIds: List<String>.from(json['destinationIds'] ?? []),
        estimatedDurationMinutes: json['estimatedDurationMinutes'],
        isCompleted: json['isCompleted'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'destinationIds': destinationIds,
        'estimatedDurationMinutes': estimatedDurationMinutes,
        'isCompleted': isCompleted,
      };
}
