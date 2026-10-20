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
    final displayOldPrice =
        (resolvedCompare != null && resolvedCompare > resolvedUnit)
        ? l10n.formatPrice(resolvedCompare)
        : (product.oldPrice?.isNotEmpty == true ? product.oldPrice : null);

    final double? savingAmount =
        (resolvedCompare != null && resolvedCompare > resolvedUnit)
        ? (resolvedCompare - resolvedUnit)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Store Header Banner if available
        if (product.storeName != null && product.storeName!.isNotEmpty) ...[
          Container(
            padding: const EdgeInsetsDirectional.only(
              start: 10,
              end: 12,
              top: 8,
              bottom: 8,
            ),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      final storeSlug = product.storeSlug?.trim();
                      if (storeSlug == null || storeSlug.isEmpty) {
                        context.push(AppRoutes.stores);
                        return;
                      }
                      context.push(
                        AppRoutes.products,
                        extra: ProductsListingArgs(
                          storeSlug: storeSlug,
                          title: product.storeName!,
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(
                        start: 4,
                        end: 8,
                        top: 4,
                        bottom: 4,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.storefront_rounded,
                              color: colorScheme.onPrimary,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        product.storeName!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.cairo(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.verified_rounded,
                                      size: 14,
                                      color: colorScheme.primary,
                                    ),
                                  ],
                                ),
                                Text(
                                  l10n.pick(
                                    ar: 'متجر رسمي موثوق',
                                    en: 'Verified Official Store',
                                  ),
                                  style: GoogleFonts.cairo(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => context.push(AppRoutes.stores),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: Text(
                      l10n.pick(ar: 'المتاجر', en: 'Stores'),
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],

        // Category & Brand Chips
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (product.category?.isNotEmpty == true)
              _InfoChip(
                icon: Icons.category_outlined,
                label: product.category!,
                color: AppColors.primaryFor(context),
              ),
            if (product.brand?.isNotEmpty == true)
              _InfoChip(
                icon: Icons.verified_outlined,
                label: product.brand!,
                color: const Color(0xFF6366F1),
              ),
          ],
        ),
        const SizedBox(height: 10),

        // Product Title
        Text(
          product.title,
          style: GoogleFonts.cairo(
            fontSize: 21,
            fontWeight: FontWeight.w900,
            height: 1.3,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 14),

        // Price Card Section
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.6),
            ),
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (displayPrice.isNotEmpty)
                    Text(
                      displayPrice,
                      style: GoogleFonts.cairo(
                        fontSize: 26,
                        height: 1.1,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryFor(context),
                      ),
                    ),
                  const SizedBox(width: 10),
                  if (displayOldPrice != null && displayOldPrice.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        displayOldPrice,
                        style: GoogleFonts.cairo(
                          fontSize: 15,
                          height: 1.1,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.7,
                          ),
                          decoration: TextDecoration.lineThrough,
                          decorationColor: const Color(
                            0xFFE53935,
                          ).withValues(alpha: 0.8),
                          decorationThickness: 1.8,
                        ),
                      ),
                    ),
                  const Spacer(),
                  if (product.discountBadge?.isNotEmpty == true)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE53935), Color(0xFFD32F2F)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFFE53935,
                            ).withValues(alpha: 0.25),
                            blurRadius: 6,
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
              if (savingAmount != null && savingAmount > 0) ...[
                const SizedBox(height: 6),
                Text(
                  l10n.pick(
                    ar: '🎉 وفرت ${l10n.formatPrice(savingAmount)} من السعر الأصلي!',
                    en: '🎉 You save ${l10n.formatPrice(savingAmount)} on this deal!',
                  ),
                  style: GoogleFonts.cairo(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF10B981),
                  ),
                ),
              ],
            ],
          ),
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
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: product.isOutOfStock
                    ? const Color(0xFFE53935).withValues(alpha: 0.1)
                    : (product.stockQuantity != null &&
                          product.stockQuantity! <= 5)
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
                        : (product.stockQuantity != null &&
                              product.stockQuantity! <= 5)
                        ? const Color(0xFFF59E0B)
                        : const Color(0xFF10B981),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    product.isOutOfStock
                        ? l10n.pick(ar: 'نفذت الكمية', en: 'Out of Stock')
                        : (product.stockQuantity != null &&
                              product.stockQuantity! <= 5)
                        ? l10n.pick(
                            ar: 'بقي ${product.stockQuantity} فقط!',
                            en: 'Only ${product.stockQuantity} left!',
                          )
                        : l10n.pick(ar: 'متوفر في المخزون', en: 'In Stock'),
                    style: GoogleFonts.cairo(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: product.isOutOfStock
                          ? const Color(0xFFE53935)
                          : (product.stockQuantity != null &&
                                product.stockQuantity! <= 5)
                          ? const Color(0xFFF59E0B)
                          : const Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Value & Guarantee Badges Grid
        _buildTrustBadges(context, l10n),
      ],
    );
  }

  Widget _buildTrustBadges(BuildContext context, AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;

    final badges = [
      {
        'icon': Icons.local_shipping_outlined,
        'title': l10n.pick(ar: 'شحن سريع', en: 'Fast Delivery'),
      },
      {
        'icon': Icons.verified_user_outlined,
        'title': l10n.pick(ar: 'أصلي ومضمون', en: '100% Authentic'),
      },
      {
        'icon': Icons.change_circle_outlined,
        'title': l10n.pick(ar: 'إرجاع واستبدال', en: 'Easy Returns'),
      },
      {
        'icon': Icons.lock_outline_rounded,
        'title': l10n.pick(ar: 'دفع آمن 100%', en: 'Secure Pay'),
      },
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: badges.map((b) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                b['icon'] as IconData,
                size: 20,
                color: AppColors.primaryFor(context),
              ),
              const SizedBox(height: 4),
              Text(
                b['title'] as String,
                style: GoogleFonts.cairo(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
