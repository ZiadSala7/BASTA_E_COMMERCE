// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/extensions/app_localizations_x.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/widgets/products/product_card.dart';
import '../../../../core/widgets/status/empty_state.dart';
import '../../../../l10n/app_localizations.dart';
import '../widgets/home_featured_products_section.dart';

class HomeSearchResultsSection extends StatelessWidget {
  final String query;
  final List<HomeFeaturedProduct> products;
  final bool isLoading;
  final String? errorMessage;
  final Set<String> addingProductIds;
  final Set<String> favoriteProductIds;
  final Set<String> updatingFavoriteProductIds;
  final ValueChanged<HomeFeaturedProduct> onProductTap;
  final ValueChanged<HomeFeaturedProduct> onAddToCart;
  final ValueChanged<HomeFeaturedProduct> onFavoriteTap;
  final VoidCallback onRetry;

  const HomeSearchResultsSection({
    super.key,
    required this.query,
    required this.products,
    required this.isLoading,
    required this.errorMessage,
    required this.addingProductIds,
    required this.favoriteProductIds,
    required this.updatingFavoriteProductIds,
    required this.onProductTap,
    required this.onAddToCart,
    required this.onFavoriteTap,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SearchHeader(query: query),
          const SizedBox(height: 12),
          if (isLoading)
            const SizedBox(
              height: 220,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (errorMessage != null)
            EmptyState(
              icon: Icons.wifi_off_rounded,
              title: l10n.pick(
                ar: 'تعذر البحث الآن',
                en: 'Search is unavailable',
              ),
              message: errorMessage,
              actionLabel: l10n.pick(ar: 'حاول مرة أخرى', en: 'Try Again'),
              onActionTap: onRetry,
            )
          else if (products.isEmpty)
            EmptyState(
              icon: Icons.search_off_rounded,
              title: l10n.pick(ar: 'لا توجد نتائج', en: 'No results found'),
              message: l10n.pick(
                ar: 'جرّب كلمة بحث مختلفة.',
                en: 'Try a different search term.',
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: products.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.58,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (context, index) {
                final product = products[index];
                return ProductCard(
                  id: product.id,
                  title: product.title,
                  price: product.price,
                  oldPrice: product.oldPrice,
                  storeName: product.storeName,
                  imageUrl: product.imageUrl,
                  discountBadge: product.discountLabel,
                  reviewCount: product.reviewCount,
                  isFavorite: favoriteProductIds.contains(product.id),
                  isFavoriteUpdating: updatingFavoriteProductIds.contains(
                    product.id,
                  ),
                  isAddingToCart: addingProductIds.contains(product.id),
                  onTap: () => onProductTap(product),
                  onFavoriteTap: () => onFavoriteTap(product),
                  onAddToCart: () => onAddToCart(product),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _SearchHeader extends StatelessWidget {
  final String query;

  const _SearchHeader({required this.query});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withOpacity(0.12)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, color: AppColors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l10n.pick(
                  ar: 'نتائج البحث عن "$query"',
                  en: 'Search results for "$query"',
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.cairo(
                  color: colorScheme.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
