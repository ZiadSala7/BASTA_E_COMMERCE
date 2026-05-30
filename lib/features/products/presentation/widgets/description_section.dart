import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/product_detail_args.dart';

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

class _AttributesSection extends StatelessWidget {
  final Map<String, dynamic> attributes;

  const _AttributesSection({required this.attributes});

  @override
  Widget build(BuildContext context) {
    final visibleAttributes = attributes.entries
        .where((entry) {
          final key = entry.key.toLowerCase().trim();
          final value = entry.value?.toString().trim() ?? '';
          return value.isNotEmpty && key != 'color' && key != 'size';
        })
        .take(8)
        .toList();

    if (visibleAttributes.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Specifications',
          style: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        ...visibleAttributes.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 120,
                  child: Text(
                    entry.key,
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    entry.value.toString(),
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
