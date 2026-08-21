import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/extensions/app_localizations_x.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

class BottomActionBar extends StatelessWidget {
  final int quantity;
  final double unitPrice;
  final int? stockQuantity;
  final bool isOutOfStock;
  final ValueChanged<int>? onQuantityChanged;
  final VoidCallback? onAddToCart;
  final VoidCallback? onBuyNow;
  final bool isAddingToCart;

  const BottomActionBar({
    super.key,
    this.quantity = 1,
    this.unitPrice = 0.0,
    this.stockQuantity,
    this.isOutOfStock = false,
    this.onQuantityChanged,
    this.onAddToCart,
    this.onBuyNow,
    this.isAddingToCart = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final maxQuantity = (stockQuantity != null && stockQuantity! > 0)
        ? stockQuantity!
        : 99;
    final totalPrice = unitPrice * quantity;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                // Quantity Stepper
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.8),
                    ),
                  ),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: (quantity > 1 && !isOutOfStock && onQuantityChanged != null)
                            ? () => onQuantityChanged!(quantity - 1)
                            : null,
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(14),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          child: Icon(
                            Icons.remove_rounded,
                            size: 18,
                            color: quantity > 1 && !isOutOfStock && onQuantityChanged != null
                                ? colorScheme.onSurface
                                : colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          quantity.toString(),
                          style: GoogleFonts.cairo(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w900,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: (quantity < maxQuantity && !isOutOfStock && onQuantityChanged != null)
                            ? () => onQuantityChanged!(quantity + 1)
                            : null,
                        borderRadius: const BorderRadius.horizontal(
                          right: Radius.circular(14),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          child: Icon(
                            Icons.add_rounded,
                            size: 18,
                            color: quantity < maxQuantity && !isOutOfStock && onQuantityChanged != null
                                ? colorScheme.onSurface
                                : colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),

                // Total Price for selected quantity
                if (totalPrice > 0)
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.pick(ar: 'المجموع', en: 'Total'),
                          style: GoogleFonts.cairo(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurfaceVariant,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.formatPrice(totalPrice),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cairo(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Action Buttons
                Expanded(
                  flex: 3,
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: (isAddingToCart || isOutOfStock || onAddToCart == null)
                                ? null
                                : onAddToCart,
                            icon: isAddingToCart
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(
                                    Icons.add_shopping_cart_rounded,
                                    size: 17,
                                  ),
                            label: Text(
                              isOutOfStock
                                  ? l10n.pick(ar: 'نفذ', en: 'Sold Out')
                                  : l10n.pick(ar: 'أضف للسلة', en: 'Add to Cart'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.cairo(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: (isAddingToCart || isOutOfStock || onBuyNow == null)
                              ? null
                              : onBuyNow,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E293B),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.flash_on_rounded,
                                size: 16,
                                color: Color(0xFFFFB800),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                l10n.pick(ar: 'شراء', en: 'Buy'),
                                style: GoogleFonts.cairo(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
