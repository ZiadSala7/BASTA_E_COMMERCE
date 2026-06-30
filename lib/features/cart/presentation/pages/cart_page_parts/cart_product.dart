part of '../cart_page.dart';

class _CartProduct {
  const _CartProduct({
    required this.id,
    required this.productId,
    required this.title,
    required this.storeId,
    required this.storeName,
    required this.storeSlug,
    required this.price,
    required this.unitPrice,
    required this.quantity,
    required this.badge,
    required this.accent,
    required this.imageUrl,
    this.isFavorite = false,
    this.darkImage = false,
  });

  final String id;
  final String productId;
  final String title;
  final String? storeId;
  final String storeName;
  final String? storeSlug;
  final String price;
  final double unitPrice;
  final int quantity;
  final String badge;
  final Color accent;
  final String imageUrl;
  final bool isFavorite;
  final bool darkImage;

  String get removeProductId => productId.isEmpty ? id : productId;

  String get storeGroupKey {
    final slug = storeSlug?.trim();
    if (slug != null && slug.isNotEmpty) return slug;

    final name = storeName.trim();
    if (name.isNotEmpty) return name;

    return 'unknown-store';
  }

  factory _CartProduct.fromEntity(CartItemEntity item) {
    return _CartProduct(
      id: item.id,
      productId: item.productId,
      title: item.name,
      storeId: item.storeId,
      storeName: item.storeName.trim(),
      storeSlug: item.storeSlug,
      price: _money(item.activePrice),
      unitPrice: item.activePrice,
      quantity: item.quantity,
      badge: 'NEW',
      accent: AppColors.primary,
      imageUrl: item.imageUrl,
    );
  }

  _CartProduct copyWith({
    String? title,
    String? price,
    int? quantity,
    bool? isFavorite,
  }) {
    return _CartProduct(
      id: id,
      productId: productId,
      title: title ?? this.title,
      storeId: storeId,
      storeName: storeName,
      storeSlug: storeSlug,
      price: price ?? this.price,
      unitPrice: unitPrice,
      quantity: quantity ?? this.quantity,
      badge: badge,
      accent: accent,
      imageUrl: imageUrl,
      isFavorite: isFavorite ?? this.isFavorite,
      darkImage: darkImage,
    );
  }
}
