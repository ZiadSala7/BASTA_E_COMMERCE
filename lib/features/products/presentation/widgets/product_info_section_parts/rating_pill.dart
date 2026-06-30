part of '../product_info_section.dart';

class _RatingPill extends StatelessWidget {
  final ProductDetailArgs product;

  const _RatingPill({required this.product});

  @override
  Widget build(BuildContext context) {
    final label = _label();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 17, color: Color(0xFFF59E0B)),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF92400E),
            ),
          ),
        ],
      ),
    );
  }

  String _label() {
    final rating = product.rating;
    final reviews = product.reviewCount;
    if (rating == null && reviews == null) return 'No reviews yet';
    if (rating == null) return '$reviews reviews';
    if (reviews == null) return rating.toStringAsFixed(1);
    return '${rating.toStringAsFixed(1)} ($reviews)';
  }
}
