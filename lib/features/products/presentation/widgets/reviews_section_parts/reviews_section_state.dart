part of '../reviews_section.dart';

class _ReviewsSectionState extends State<ReviewsSection> {
  final TextEditingController _commentController = TextEditingController();
  int _rating = 5;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Reviews',
              style: GoogleFonts.cairo(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                '${widget.reviews.length}',
                style: GoogleFonts.cairo(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _ReviewComposer(
          rating: _rating,
          commentController: _commentController,
          isSubmitting: widget.isSubmitting,
          onRatingChanged: (rating) => setState(() => _rating = rating),
          onSubmit: _submitReview,
        ),
        const SizedBox(height: 12),
        if (widget.isLoading)
          const _ReviewsLoading()
        else if (widget.error != null)
          _ReviewsMessage(
            icon: Icons.error_outline_rounded,
            title: 'Reviews unavailable',
            message: widget.error!,
            actionLabel: 'Retry',
            onAction: widget.onRetry,
          )
        else if (widget.reviews.isEmpty)
          const _ReviewsMessage(
            icon: Icons.rate_review_outlined,
            title: 'No reviews yet',
            message:
                'Be the first customer to share a review for this product.',
          )
        else
          ...widget.reviews
              .take(3)
              .map(
                (review) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _ReviewItem(review: review),
                ),
              ),
      ],
    );
  }

  Future<void> _submitReview() async {
    final comment = _commentController.text.trim();
    if (comment.isEmpty || widget.isSubmitting) return;

    final submitted = await widget.onSubmitReview(_rating, comment);
    if (!mounted) return;
    if (!submitted) return;

    _commentController.clear();
    setState(() => _rating = 5);
  }
}
