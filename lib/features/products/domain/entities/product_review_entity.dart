class ProductReviewEntity {
  final String id;
  final String authorName;
  final double rating;
  final String comment;
  final DateTime? createdAt;

  const ProductReviewEntity({
    required this.id,
    required this.authorName,
    required this.rating,
    required this.comment,
    this.createdAt,
  });
}
