part of '../product_info_section.dart';

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
