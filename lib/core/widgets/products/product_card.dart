import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../l10n/app_localizations.dart';
import '../../extensions/app_localizations_x.dart';

class ProductCard extends StatelessWidget {
  final String id;
  final String title;
  final String price;
  final String? oldPrice;
  final String? storeName;
  final String? imageUrl;
  final String? discountBadge;
  final int? rating;
  final int? reviewCount;
  final bool isFavorite;
  final bool isFavoriteUpdating;
  final bool isAddingToCart;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onAddToCart;

  const ProductCard({
    super.key,
    required this.id,
    required this.title,
    required this.price,
    this.oldPrice,
    this.storeName,
    this.imageUrl,
    this.discountBadge,
    this.rating,
    this.reviewCount,
    this.isFavorite = false,
    this.isFavoriteUpdating = false,
    this.isAddingToCart = false,
    this.onTap,
    this.onFavoriteTap,
    this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFE4E7F0);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.08),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: AspectRatio(
                  aspectRatio: 1.18,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                colorScheme.primaryContainer.withValues(
                                  alpha: isDark ? 0.18 : 0.26,
                                ),
                                colorScheme.surfaceContainerHighest.withValues(
                                  alpha: isDark ? 0.22 : 0.64,
                                ),
                              ],
                            ),
                          ),
                          child: _ProductImage(imageUrl: imageUrl),
                        ),
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.06),
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.08),
                                ],
                                stops: const [0, 0.46, 1],
                              ),
                            ),
                          ),
                        ),
                        if (discountBadge != null)
                          PositionedDirectional(
                            top: 8,
                            start: 8,
                            child: _ProductBadge(label: discountBadge!),
                          ),
                        PositionedDirectional(
                          top: 8,
                          end: 8,
                          child: _FavoriteButton(
                            isFavorite: isFavorite,
                            isUpdating: isFavoriteUpdating,
                            onTap: onFavoriteTap,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cairo(
                          fontSize: 13.2,
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurface,
                          height: 1.24,
                        ),
                      ),
                      if (storeName != null && storeName!.isNotEmpty) ...[
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Icon(
                              Icons.storefront_rounded,
                              size: 13,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                storeName!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.cairo(
                                  fontSize: 10.8,
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.onSurfaceVariant,
                                  height: 1.1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 7),
                      if (rating != null || reviewCount != null)
                        _RatingMeta(rating: rating, reviewCount: reviewCount),
                      const Spacer(),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Text(
                              price,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.cairo(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w900,
                                color: colorScheme.primary,
                                height: 1.08,
                              ),
                            ),
                          ),
                          if (oldPrice != null && oldPrice!.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                oldPrice!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.cairo(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.64),
                                  decoration: TextDecoration.lineThrough,
                                  decorationColor: colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.58),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (onAddToCart != null) ...[
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          height: 34,
                          child: ElevatedButton.icon(
                            onPressed: isAddingToCart ? null : onAddToCart,
                            icon: isAddingToCart
                                ? const SizedBox(
                                    width: 15,
                                    height: 15,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(
                                    Icons.add_shopping_cart_rounded,
                                    size: 16,
                                  ),
                            label: Text(
                              AppLocalizations.of(
                                context,
                              )!.pick(ar: 'إضافة للسلة', en: 'Add to Cart'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.cairo(
                                fontSize: 11.8,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: colorScheme.primary
                                  .withValues(alpha: 0.62),
                              disabledForegroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RatingMeta extends StatelessWidget {
  const _RatingMeta({required this.rating, required this.reviewCount});

  final int? rating;
  final int? reviewCount;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        if (rating != null)
          Container(
            height: 22,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFB800).withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.star_rounded,
                  color: Color(0xFFFFB800),
                  size: 14,
                ),
                const SizedBox(width: 2),
                Text(
                  rating.toString(),
                  style: GoogleFonts.cairo(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        if (reviewCount != null) ...[
          if (rating != null) const SizedBox(width: 6),
          Expanded(
            child: Text(
              '($reviewCount)',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.cairo(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.72),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return const _ImageFallback();
    }

    return Image.network(
      imageUrl!,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => const _ImageFallback(),
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const _ImageFallback();
      },
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          color: colorScheme.surface.withValues(alpha: 0.82),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.inventory_2_outlined,
          color: colorScheme.primary,
          size: 30,
        ),
      ),
    );
  }
}

class _ProductBadge extends StatelessWidget {
  const _ProductBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE23B3B),
        borderRadius: BorderRadius.circular(7),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE23B3B).withValues(alpha: 0.22),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        label,
        style: GoogleFonts.cairo(
          color: Colors.white,
          fontSize: 10.5,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({
    required this.isFavorite,
    required this.isUpdating,
    this.onTap,
  });

  final bool isFavorite;
  final bool isUpdating;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surface.withValues(alpha: 0.94),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: isUpdating ? null : onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 32,
          height: 32,
          child: isUpdating
              ? const Padding(
                  padding: EdgeInsets.all(8),
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(
                  isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: isFavorite
                      ? const Color(0xFFE23B3B)
                      : colorScheme.onSurfaceVariant,
                  size: 18,
                ),
        ),
      ),
    );
  }
}
