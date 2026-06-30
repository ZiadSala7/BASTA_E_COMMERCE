part of '../reviews_section.dart';

class _ReviewItem extends StatelessWidget {
  final ProductReviewEntity review;

  const _ReviewItem({required this.review});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final initial = review.authorName.trim().isEmpty
        ? 'C'
        : review.authorName.trim().characters.first.toUpperCase();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.38),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary,
                child: Text(
                  initial,
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.authorName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Row(
                      children: [
                        ...List.generate(
                          5,
                          (index) => Icon(
                            index < review.rating.round()
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: const Color(0xFFF59E0B),
                            size: 15,
                          ),
                        ),
                        if (review.createdAt != null) ...[
                          const SizedBox(width: 6),
                          Text(
                            _dateLabel(review.createdAt!),
                            style: GoogleFonts.cairo(
                              fontSize: 11.5,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              review.comment,
              style: GoogleFonts.cairo(
                fontSize: 13,
                height: 1.5,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _dateLabel(DateTime date) {
    final normalized = date.toLocal();
    return '${normalized.year}/${normalized.month.toString().padLeft(2, '0')}/${normalized.day.toString().padLeft(2, '0')}';
  }
}
