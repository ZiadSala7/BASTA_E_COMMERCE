// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import '../../../../core/extensions/app_localizations_x.dart';
import '../../../../core/api/api_keys.dart';
import '../../../../core/widgets/common/section_header.dart';
import '../../../../core/widgets/products/product_card.dart';
import '../../../../l10n/app_localizations.dart';

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
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Directionality(
          textDirection: l10n.isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: SectionHeader(
            title: title ?? l10n.chosenForYou,
            actionLabel: l10n.showAll,
            onActionTap: onShowAllTap,
            padding: const EdgeInsets.symmetric(horizontal: 20),
          ),
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
  }
}

class HomeFeaturedProduct {
  final String id;
  final String title;
  final String price;
  final String? oldPrice;
  final String imageUrl;
  final String? imageAsset;
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
