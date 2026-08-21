part of '../cart_page.dart';

class _CartProduct {
  const _CartProduct({
    required this.id,
    this.cartItemId = '',
    this.variantId = '',
    required this.productId,
    required this.title,
    required this.storeId,
    required this.storeName,
    required this.storeSlug,
    required this.price,
    required this.unitPrice,
    this.compareAtPrice,
    this.discountEndDate,
    required this.quantity,
    this.stockQuantity = 0,
    this.sku,
    this.variantImageId,
    this.isSaleActive = false,
    this.weightInKg,
    this.attributes,
    this.color,
    this.size,
    required this.badge,
    required this.accent,
    required this.imageUrl,
    this.isFavorite = false,
    this.darkImage = false,
  });

  final String id;
  final String cartItemId;
  final String variantId;
  final String productId;
  final String title;
  final String? storeId;
  final String storeName;
  final String? storeSlug;
  final String price;
  final double unitPrice;
  final double? compareAtPrice;
  final String? discountEndDate;
  final int quantity;
  final int stockQuantity;
  final String? sku;
  final String? variantImageId;
  final bool isSaleActive;
  final String? weightInKg;
  final Map<String, dynamic>? attributes;
  final String? color;
  final String? size;
  final String badge;
  final Color accent;
  final String imageUrl;
  final bool isFavorite;
  final bool darkImage;

  String get effectiveVariantId =>
      variantId.isNotEmpty ? variantId : (productId.isNotEmpty ? productId : id);

  String get removeProductId => effectiveVariantId;

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
      cartItemId: item.cartItemId,
      variantId: item.variantId,
      productId: item.productId,
      title: item.name,
      storeId: item.storeId,
      storeName: item.storeName.trim(),
      storeSlug: item.storeSlug,
      price: _money(item.activePrice),
      unitPrice: item.activePrice,
      compareAtPrice: item.compareAtPrice,
      discountEndDate: item.discountEndDate,
      quantity: item.quantity,
      stockQuantity: item.stockQuantity,
      sku: item.sku,
      variantImageId: item.variantImageId,
      isSaleActive: item.isSaleActive,
      weightInKg: item.weightInKg,
      attributes: item.attributes,
      color: item.color,
      size: item.size,
      badge: item.isSaleActive ? 'SALE' : 'NEW',
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
      cartItemId: cartItemId,
      variantId: variantId,
      productId: productId,
      title: title ?? this.title,
      storeId: storeId,
      storeName: storeName,
      storeSlug: storeSlug,
      price: price ?? this.price,
      unitPrice: unitPrice,
      compareAtPrice: compareAtPrice,
      discountEndDate: discountEndDate,
      quantity: quantity ?? this.quantity,
      stockQuantity: stockQuantity,
      sku: sku,
      variantImageId: variantImageId,
      isSaleActive: isSaleActive,
      weightInKg: weightInKg,
      attributes: attributes,
      color: color,
      size: size,
      badge: badge,
      accent: accent,
      imageUrl: imageUrl,
      isFavorite: isFavorite ?? this.isFavorite,
      darkImage: darkImage,
    );
  }
}
