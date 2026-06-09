class ContextSignalModel {
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
