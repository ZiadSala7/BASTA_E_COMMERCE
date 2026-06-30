part of '../description_section.dart';

class DescriptionSection extends StatelessWidget {
  final ProductDetailArgs product;

  const DescriptionSection({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Product details',
          style: GoogleFonts.cairo(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        if (product.description != null && product.description!.isNotEmpty)
          Text(
            product.description!,
            style: GoogleFonts.cairo(
              fontSize: 14.5,
              color: const Color(0xFF6B7280),
              height: 1.6,
            ),
          )
        else
          Text(
            'No description available for this product.',
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: const Color(0xFF9CA3AF),
              fontStyle: FontStyle.italic,
              height: 1.6,
            ),
          ),
        if (product.tags != null && product.tags!.isNotEmpty) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: product.tags!.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  tag,
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
        if (product.attributes != null && product.attributes!.isNotEmpty) ...[
          const SizedBox(height: 16),
          _AttributesSection(attributes: product.attributes!),
        ],
      ],
    );
  }
}
