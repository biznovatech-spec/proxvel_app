class AspectScoreModel {
  final String aspect;
  final double score;

  AspectScoreModel({required this.aspect, required this.score});

  factory AspectScoreModel.fromJson(Map<String, dynamic> json) => AspectScoreModel(
        aspect: json['aspect'],
        score: json['score'].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'aspect': aspect,
        'score': score,
      };
}
