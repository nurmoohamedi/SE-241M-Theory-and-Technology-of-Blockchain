class ReviewEntity {
  final int rating;
  final String comment;

  ReviewEntity({required this.rating, required this.comment});

  factory ReviewEntity.fromJson(Map<String, dynamic> json) {
    return ReviewEntity(
      rating: json['rating'],
      comment: json['comment'],
    );
  }
}
