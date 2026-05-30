// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/utils/app_colors.dart';
import '../models/product_detail_args.dart';

class ProductInfoSection extends StatelessWidget {
  final ProductDetailArgs product;

  const ProductInfoSection({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (product.category?.isNotEmpty == true)
              _InfoChip(
                icon: Icons.category_outlined,
                label: product.category!,
                color: AppColors.primary,
              ),
            if (product.brand?.isNotEmpty == true)
              _InfoChip(
                icon: Icons.verified_outlined,
                label: product.brand!,
                color: const Color(0xFF0F766E),
              ),
            _InfoChip(
              icon: product.isOutOfStock
                  ? Icons.remove_shopping_cart_outlined
                  : Icons.local_shipping_outlined,
              label: product.stockStatus,
              color: product.isOutOfStock
                  ? AppColors.badgeRed
                  : const Color(0xFF16803C),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          product.title,
          style: GoogleFonts.cairo(
            fontSize: 23,
            fontWeight: FontWeight.w900,
            height: 1.22,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (product.price.isNotEmpty)
              Flexible(
                child: Text(
                  product.price,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                    fontSize: 28,
                    height: 1,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                  ),
                ),
              ),
            if (product.oldPrice?.isNotEmpty == true) ...[
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  product.oldPrice!,
                  style: GoogleFonts.cairo(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurfaceVariant,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            _RatingPill(product: product),
            if (product.stockQuantity != null &&
                product.stockQuantity! > 0) ...[
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  product.stockQuantity! <= 5
                      ? 'Only ${product.stockQuantity} left'
                      : '${product.stockQuantity} available',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                    color: product.stockQuantity! <= 5
                        ? const Color(0xFFC2410C)
                        : colorScheme.onSurfaceVariant,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.cairo(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

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
