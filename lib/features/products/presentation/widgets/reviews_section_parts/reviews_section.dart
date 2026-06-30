part of '../reviews_section.dart';

class ReviewsSection extends StatefulWidget {
  final List<ProductReviewEntity> reviews;
  final bool isLoading;
  final bool isSubmitting;
  final String? error;
  final VoidCallback onRetry;
  final Future<bool> Function(int rating, String comment) onSubmitReview;

  const ReviewsSection({
    super.key,
    required this.reviews,
    required this.isLoading,
    required this.isSubmitting,
    required this.error,
    required this.onRetry,
    required this.onSubmitReview,
  });

  @override
  State<ReviewsSection> createState() => _ReviewsSectionState();
}
