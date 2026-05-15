// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import '../../../../core/extensions/app_localizations_x.dart';
import '../../../../core/widgets/common/section_header.dart';
import '../../../../core/widgets/products/product_card.dart';
import '../../../../l10n/app_localizations.dart';

class HomeFeaturedProductsSection extends StatelessWidget {
  final List<HomeFeaturedProduct> items;
  final String? title;
  final VoidCallback? onShowAllTap;
  final ValueChanged<HomeFeaturedProduct>? onProductTap;
  final bool showRisingBadge;

  const HomeFeaturedProductsSection({
    super.key,
    required this.items,
    this.title,
    this.onShowAllTap,
    this.onProductTap,
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
                  onTap: onProductTap == null
                      ? null
                      : () => onProductTap!(product),
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
    return HomeFeaturedProduct(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? json['name'] ?? '').toString(),
      price: (json['price'] ?? json['formatted_price'] ?? '').toString(),
      oldPrice: (json['old_price'] ?? json['oldPrice'])?.toString(),
      imageUrl: (json['image_url'] ?? json['imageUrl'] ?? '').toString(),
      badgeText: (json['badge_text'] ?? json['badgeText'] ?? '').toString(),
      discountLabel: (json['discount_label'] ?? json['discountLabel'])
          ?.toString(),
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
}
