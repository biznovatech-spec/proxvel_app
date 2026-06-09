class FeedbackModel {
  final String userId;
  final String destinationId;
  final double rating;
  final String comment;
  final String interactionType;

  FeedbackModel({
    required this.userId,
    required this.destinationId,
    required this.rating,
    required this.comment,
    required this.interactionType,
  });

  factory FeedbackModel.fromJson(Map<String, dynamic> json) => FeedbackModel(
        userId: json['userId'],
        destinationId: json['destinationId'],
        rating: json['rating'].toDouble(),
        comment: json['comment'],
        interactionType: json['interactionType'],
      );

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'destinationId': destinationId,
        'rating': rating,
        'comment': comment,
        'interactionType': interactionType,
      };
}
