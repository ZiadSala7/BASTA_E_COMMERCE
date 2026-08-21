part of '../product_info_section.dart';

class ProductInfoSection extends StatelessWidget {
  final ProductDetailArgs product;
  final VoidCallback? onReviewTap;

  const ProductInfoSection({
    super.key,
    required this.product,
    this.onReviewTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final resolvedUnit = product.effectiveUnitPrice;
    final displayPrice = resolvedUnit > 0
        ? l10n.formatPrice(resolvedUnit)
        : product.price;

    final resolvedCompare = product.effectiveCompareAtPrice;
    final displayOldPrice = (resolvedCompare != null && resolvedCompare > resolvedUnit)
        ? l10n.formatPrice(resolvedCompare)
        : (product.oldPrice?.isNotEmpty == true ? product.oldPrice : null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category, Store, Brand Chips
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
            if (product.storeName?.isNotEmpty == true)
              _InfoChip(
                icon: Icons.storefront_rounded,
                label: product.storeName!,
                color: const Color(0xFF0F766E),
              ),
            if (product.brand?.isNotEmpty == true)
              _InfoChip(
                icon: Icons.verified_outlined,
                label: product.brand!,
                color: const Color(0xFF6366F1),
              ),
          ],
        ),
        const SizedBox(height: 12),

        // Product Title
        Text(
          product.title,
          style: GoogleFonts.cairo(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            height: 1.25,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 14),

        // Price Row with High Contrast Visibility
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 10,
          runSpacing: 6,
          children: [
            if (displayPrice.isNotEmpty)
              Text(
                displayPrice,
                style: GoogleFonts.cairo(
                  fontSize: 26,
                  height: 1.1,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
            if (displayOldPrice != null && displayOldPrice.isNotEmpty)
              Text(
                displayOldPrice,
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  height: 1.1,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.75),
                  decoration: TextDecoration.lineThrough,
                  decorationColor: const Color(0xFFE53935).withValues(alpha: 0.8),
                  decorationThickness: 1.8,
                ),
              ),
            if (product.discountBadge?.isNotEmpty == true)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE53935),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE53935).withValues(alpha: 0.25),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  product.discountBadge!,
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 11.5,
                    height: 1,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),

        // Rating & Stock Status Row
        Row(
          children: [
            InkWell(
              onTap: onReviewTap,
              borderRadius: BorderRadius.circular(8),
              child: _RatingPill(product: product),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: product.isOutOfStock
                    ? const Color(0xFFE53935).withValues(alpha: 0.1)
                    : (product.stockQuantity != null && product.stockQuantity! <= 5)
                    ? const Color(0xFFF59E0B).withValues(alpha: 0.1)
                    : const Color(0xFF10B981).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    product.isOutOfStock
                        ? Icons.cancel_outlined
                        : Icons.check_circle_outline_rounded,
                    size: 14,
                    color: product.isOutOfStock
                        ? const Color(0xFFE53935)
                        : (product.stockQuantity != null && product.stockQuantity! <= 5)
                        ? const Color(0xFFF59E0B)
                        : const Color(0xFF10B981),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    product.isOutOfStock
                        ? l10n.pick(ar: 'نفذت الكمية', en: 'Out of Stock')
                        : (product.stockQuantity != null && product.stockQuantity! <= 5)
                        ? l10n.pick(
                            ar: 'بقي ${product.stockQuantity} فقط!',
                            en: 'Only ${product.stockQuantity} left!',
                          )
                        : l10n.pick(ar: 'متوفر في المخزون', en: 'In Stock'),
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: product.isOutOfStock
                          ? const Color(0xFFE53935)
                          : (product.stockQuantity != null && product.stockQuantity! <= 5)
                          ? const Color(0xFFF59E0B)
                          : const Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
