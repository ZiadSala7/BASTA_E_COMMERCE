part of '../home_featured_products_section.dart';

class HomeFeaturedProductsSection extends StatelessWidget {
  final List<HomeFeaturedProduct> items;
  final String? title;
  final VoidCallback? onShowAllTap;
  final ValueChanged<HomeFeaturedProduct>? onProductTap;
  final ValueChanged<HomeFeaturedProduct>? onAddToCart;
  final ValueChanged<HomeFeaturedProduct>? onFavoriteTap;
  final Set<String> addingProductIds;
  final Set<String> favoriteProductIds;
  final Set<String> updatingFavoriteProductIds;
  final bool showRisingBadge;
  final HomeProductsSectionVariant variant;

  const HomeFeaturedProductsSection({
    super.key,
    required this.items,
    this.title,
    this.onShowAllTap,
    this.onProductTap,
    this.onAddToCart,
    this.onFavoriteTap,
    this.addingProductIds = const <String>{},
    this.favoriteProductIds = const <String>{},
    this.updatingFavoriteProductIds = const <String>{},
    this.showRisingBadge = true,
    this.variant = HomeProductsSectionVariant.standard,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeading(
          title: title ?? l10n.chosenForYou,
          subtitle: variant == HomeProductsSectionVariant.specialOffer
              ? l10n.specialOfferBody
              : null,
          actionLabel: l10n.showAll,
          onActionTap: onShowAllTap,
          variant: variant,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 274,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final product = items[index];

              return SizedBox(
                width: 160,
                child: ProductCard(
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
                  onTap: onProductTap == null
                      ? null
                      : () => onProductTap!(product),
                  onFavoriteTap: onFavoriteTap == null
                      ? null
                      : () => onFavoriteTap!(product),
                  onAddToCart: onAddToCart == null
                      ? null
                      : () => onAddToCart!(product),
                ),
              );
            },
          ),
        ),
      ],
    );

    if (variant == HomeProductsSectionVariant.standard) {
      return content;
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A221B) : const Color(0xFFFFF6EA),
        border: Border.symmetric(
          horizontal: BorderSide(
            color: isDark ? const Color(0xFF5A422D) : const Color(0xFFFFD9AA),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: content,
      ),
    );
  }
}
