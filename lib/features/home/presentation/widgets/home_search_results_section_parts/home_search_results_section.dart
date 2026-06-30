part of '../home_search_results_section.dart';

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
