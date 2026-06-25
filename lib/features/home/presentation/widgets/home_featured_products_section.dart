// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import '../../../../core/extensions/app_localizations_x.dart';
import '../../../../core/api/api_keys.dart';
import '../../../../core/widgets/common/section_header.dart';
import '../../../../core/widgets/products/product_card.dart';
import '../../../../l10n/app_localizations.dart';

enum HomeProductsSectionVariant { standard, specialOffer }

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

class _SectionHeading extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String actionLabel;
  final VoidCallback? onActionTap;
  final HomeProductsSectionVariant variant;

  const _SectionHeading({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onActionTap,
    required this.variant,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Directionality(
      textDirection: l10n.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: variant == HomeProductsSectionVariant.specialOffer
          ? _SpecialOfferHeading(
              title: title,
              subtitle: subtitle,
              actionLabel: actionLabel,
              onActionTap: onActionTap,
            )
          : SectionHeader(
              title: title,
              actionLabel: actionLabel,
              onActionTap: onActionTap,
              padding: const EdgeInsets.symmetric(horizontal: 20),
            ),
    );
  }
}

class _SpecialOfferHeading extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String actionLabel;
  final VoidCallback? onActionTap;

  const _SpecialOfferHeading({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final accent = isDark ? const Color(0xFFFFB86B) : const Color(0xFFC75A00);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: accent.withOpacity(isDark ? 0.20 : 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: accent.withOpacity(0.28)),
            ),
            child: Icon(Icons.local_offer_rounded, color: accent, size: 19),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 13.5,
                    height: 1.2,
                    fontWeight: FontWeight.w900,
                    color: accent,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 10.5,
                      height: 1.25,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          TextButton(
            onPressed: onActionTap,
            style: TextButton.styleFrom(
              foregroundColor: accent,
              minimumSize: const Size(0, 30),
              padding: const EdgeInsets.symmetric(horizontal: 6),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              actionLabel,
              style: theme.textTheme.labelSmall?.copyWith(
                color: accent,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HomeFeaturedProduct {
  final String id;
  final String title;
  final String price;
  final String? oldPrice;
  final String imageUrl;
  final String? imageAsset;
  final String? storeName;
  final String? storeSlug;
  final String badgeText;
  final String? discountLabel;
  final int reviewCount;

  const HomeFeaturedProduct({
    required this.id,
    required this.title,
    required this.price,
    this.oldPrice,
    this.imageUrl = '',
    this.imageAsset,
    this.storeName,
    this.storeSlug,
    this.badgeText = '',
    this.discountLabel,
    this.reviewCount = 0,
  });

  factory HomeFeaturedProduct.fromJson(Map<String, dynamic> json) {
    final price = _numberFromJson(json['price']);
    final compareAtPrice = _numberFromJson(
      json['compareAtPrice'] ?? json['old_price'] ?? json['oldPrice'],
    );
    final imageUrl = _imageUrlFromJson(json);

    return HomeFeaturedProduct(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? json['name'] ?? '').toString(),
      price: _formatPrice(price, json['formatted_price'] ?? json['price']),
      oldPrice: compareAtPrice == null
          ? (json['old_price'] ?? json['oldPrice'])?.toString()
          : _formatPrice(compareAtPrice, compareAtPrice),
      imageUrl: imageUrl,
      storeName: _nullableText(json['storeName'] ?? json['store_name']),
      storeSlug: _nullableText(json['storeSlug'] ?? json['store_slug']),
      badgeText: (json['badge_text'] ?? json['badgeText'] ?? '').toString(),
      discountLabel:
          (json['discount_label'] ?? json['discountLabel'])?.toString() ??
          _discountLabel(price, compareAtPrice),
      reviewCount:
          int.tryParse(
            (json['review_count'] ?? json['reviewCount'] ?? 0).toString(),
          ) ??
          0,
    );
  }

  static List<HomeFeaturedProduct> listFromJson(List<dynamic> json) {
    return json
        .whereType<Map>()
        .map(
          (item) =>
              HomeFeaturedProduct.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  static double? _numberFromJson(Object? value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static String? _nullableText(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  static String _formatPrice(double? parsed, Object? fallback) {
    if (parsed == null) return (fallback ?? '').toString();
    final value = parsed % 1 == 0
        ? parsed.toStringAsFixed(0)
        : parsed.toStringAsFixed(2);
    return 'JOD $value';
  }

  static String _imageUrlFromJson(Map<String, dynamic> json) {
    final directUrl = (json['image_url'] ?? json['imageUrl'])?.toString();
    if (directUrl != null && directUrl.isNotEmpty) {
      return _absoluteUrl(directUrl);
    }

    final images = json['images'];
    if (images is List && images.isNotEmpty) {
      final firstImage = images.whereType<Map>().firstOrNull;
      final imageUrl = firstImage?['imageUrl']?.toString();
      if (imageUrl != null && imageUrl.isNotEmpty) {
        return _absoluteUrl(imageUrl);
      }
    }

    return '';
  }

  static String _absoluteUrl(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) return url;

    final baseUrl = ApiKeys.baseUrl.endsWith('/')
        ? ApiKeys.baseUrl.substring(0, ApiKeys.baseUrl.length - 1)
        : ApiKeys.baseUrl;
    final path = url.startsWith('/') ? url : '/$url';
    return '$baseUrl$path';
  }

  static String? _discountLabel(double? price, double? compareAtPrice) {
    if (price == null || compareAtPrice == null || compareAtPrice <= price) {
      return null;
    }

    final discount = ((compareAtPrice - price) / compareAtPrice * 100).round();
    return '$discount%';
  }
}
