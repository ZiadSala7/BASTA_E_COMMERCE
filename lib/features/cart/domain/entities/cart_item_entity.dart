class ProductImageEntity {
  final String id;
  final String productId;
  final String imageUrl;
  final int orderIndex;

  const ProductImageEntity({
    required this.id,
    required this.productId,
    required this.imageUrl,
    required this.orderIndex,
  });
}

class CartItemEntity {
  final String id;
  final String cartItemId;
  final String variantId;
  final String productId;
  final String name;
  final String slug;
  final double price;
  final double activePrice;
  final double? compareAtPrice;
  final String? discountEndDate;
  final int quantity;
  final int stockQuantity;
  final String? sku;
  final String? variantImageId;
  final bool isSaleActive;
  final String? storeId;
  final String storeName;
  final String? storeSlug;
  final String? weightInKg;
  final Map<String, dynamic>? attributes;
  final String? color;
  final String? size;
  final String imageUrl;
  final List<ProductImageEntity> images;

  const CartItemEntity({
    required this.id,
    this.cartItemId = '',
    this.variantId = '',
    this.productId = '',
    required this.name,
    this.slug = '',
    required this.price,
    double? activePrice,
    this.compareAtPrice,
    this.discountEndDate,
    required this.quantity,
    this.stockQuantity = 0,
    this.sku,
    this.variantImageId,
    this.isSaleActive = false,
    this.storeId,
    this.storeName = '',
    this.storeSlug,
    this.weightInKg,
    this.attributes,
    this.color,
    this.size,
    required this.imageUrl,
    this.images = const <ProductImageEntity>[],
  }) : activePrice = activePrice ?? price;

  double get unitPrice => activePrice;
  double get totalPrice => activePrice * quantity;
  String get effectiveVariantId =>
      variantId.isNotEmpty ? variantId : (productId.isNotEmpty ? productId : id);

  CartItemEntity copyWith({
    String? id,
    String? cartItemId,
    String? variantId,
    String? productId,
    String? name,
    String? slug,
    double? price,
    double? activePrice,
    double? compareAtPrice,
    String? discountEndDate,
    int? quantity,
    int? stockQuantity,
    String? sku,
    String? variantImageId,
    bool? isSaleActive,
    String? storeId,
    String? storeName,
    String? storeSlug,
    String? weightInKg,
    Map<String, dynamic>? attributes,
    String? color,
    String? size,
    String? imageUrl,
    List<ProductImageEntity>? images,
  }) {
    return CartItemEntity(
      id: id ?? this.id,
      cartItemId: cartItemId ?? this.cartItemId,
      variantId: variantId ?? this.variantId,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      price: price ?? this.price,
      activePrice: activePrice ?? this.activePrice,
      compareAtPrice: compareAtPrice ?? this.compareAtPrice,
      discountEndDate: discountEndDate ?? this.discountEndDate,
      quantity: quantity ?? this.quantity,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      sku: sku ?? this.sku,
      variantImageId: variantImageId ?? this.variantImageId,
      isSaleActive: isSaleActive ?? this.isSaleActive,
      storeId: storeId ?? this.storeId,
      storeName: storeName ?? this.storeName,
      storeSlug: storeSlug ?? this.storeSlug,
      weightInKg: weightInKg ?? this.weightInKg,
      attributes: attributes ?? this.attributes,
      color: color ?? this.color,
      size: size ?? this.size,
      imageUrl: imageUrl ?? this.imageUrl,
      images: images ?? this.images,
    );
  }
}
