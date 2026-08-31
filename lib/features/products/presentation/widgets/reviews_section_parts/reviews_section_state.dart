part of '../reviews_section.dart';

class _ReviewsSectionState extends State<ReviewsSection> {
  final TextEditingController _commentController = TextEditingController();
  int _rating = 5;
  bool _showComposer = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final reviews = widget.reviews;

    final double averageRating = reviews.isNotEmpty
        ? (reviews.fold(0.0, (sum, r) => sum + r.rating) / reviews.length)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with count & Write Review button
          Row(
            children: [
              Icon(Icons.star_half_rounded, size: 20, color: const Color(0xFFF59E0B)),
              const SizedBox(width: 8),
              Text(
                l10n.pick(ar: 'تقييمات وآراء العملاء', en: 'Customer Reviews'),
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  '${reviews.length}',
                  style: GoogleFonts.cairo(
                    color: AppColors.primary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () => setState(() => _showComposer = !_showComposer),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _showComposer
                        ? colorScheme.surfaceContainerHighest
                        : AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _showComposer ? Icons.close_rounded : Icons.rate_review_outlined,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _showComposer
                            ? l10n.pick(ar: 'إلغاء', en: 'Cancel')
                            : l10n.pick(ar: 'أضف تقييمك', en: 'Write Review'),
                        style: GoogleFonts.cairo(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Rating summary bar
          if (reviews.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Text(
                    averageRating.toStringAsFixed(1),
                    style: GoogleFonts.cairo(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: colorScheme.onSurface,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < averageRating.round()
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: const Color(0xFFF59E0B),
                            size: 16,
                          );
                        }),
                      ),
                      Text(
                        l10n.pick(
                          ar: 'بناءً على ${reviews.length} تقييم',
                          en: 'Based on ${reviews.length} reviews',
                        ),
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],

          if (_showComposer) ...[
            const SizedBox(height: 14),
            _ReviewComposer(
              rating: _rating,
              commentController: _commentController,
              isSubmitting: widget.isSubmitting,
              onRatingChanged: (rating) => setState(() => _rating = rating),
              onSubmit: _submitReview,
            ),
          ],

          const SizedBox(height: 14),

          if (widget.isLoading)
            const _ReviewsLoading()
          else if (widget.error != null)
            _ReviewsMessage(
              icon: Icons.error_outline_rounded,
              title: l10n.pick(ar: 'تعذر تحميل التقييمات', en: 'Reviews unavailable'),
              message: widget.error!,
              actionLabel: l10n.tryAgain,
              onAction: widget.onRetry,
            )
          else if (widget.reviews.isEmpty)
            _ReviewsMessage(
              icon: Icons.rate_review_outlined,
              title: l10n.pick(ar: 'لا توجد تقييمات بعد', en: 'No reviews yet'),
              message: l10n.pick(
                ar: 'كن أول من يشارك رأيه حول هذا المنتج!',
                en: 'Be the first customer to share a review for this product.',
              ),
            )
          else
            ...widget.reviews.take(4).map(
                  (review) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _ReviewItem(review: review),
                  ),
                ),
        ],
      ),
    );
  }

  Future<void> _submitReview() async {
    final comment = _commentController.text.trim();
    if (comment.isEmpty || widget.isSubmitting) return;

    final submitted = await widget.onSubmitReview(_rating, comment);
    if (!mounted) return;
    if (!submitted) return;

    _commentController.clear();
    setState(() {
      _rating = 5;
      _showComposer = false;
    });
  }
}
