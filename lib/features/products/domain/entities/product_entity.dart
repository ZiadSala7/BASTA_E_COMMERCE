class ProductVariantEntity {
  final String id;
  final String? productId;
  final Map<String, dynamic> attributes;
  final double price;
  final double? compareAtPrice;
  final String? discountEndDate;
  final int stockQuantity;
  final String? sku;
  final String? imageId;

  const ProductVariantEntity({
    required this.id,
    this.productId,
    required this.attributes,
    required this.price,
    this.compareAtPrice,
    this.discountEndDate,
    required this.stockQuantity,
    this.sku,
    this.imageId,
  });

  bool get isOnSale {
    if (compareAtPrice == null || compareAtPrice! <= price) return false;
    if (discountEndDate == null) return true;
    final endDate = DateTime.tryParse(discountEndDate!);
    return endDate != null && endDate.isAfter(DateTime.now());
  }

  bool get isOutOfStock => stockQuantity <= 0;

  String? get size =>
      attributes['size']?.toString() ??
      attributes['Size']?.toString() ??
      attributes['weight']?.toString();

  String? get color =>
      attributes['color']?.toString() ?? attributes['Color']?.toString();
}

class ProductImageItem {
  final String id;
  final String? productId;
  final String imageUrl;
  final int orderIndex;

  const ProductImageItem({
    required this.id,
    this.productId,
    required this.imageUrl,
    required this.orderIndex,
  });
}

class ProductEntity {
  final String id;
  final String name;
  final String slug;
  final double? basePrice;
  final double? price;
  final double? compareAtPrice;
  final String? discountEndDate;
  final String? description;
  final String? imageUrl;
  final List<String>? images;
  final List<ProductImageItem> imagesList;
  final String? category;
  final String? categorySlug;
  final String? brand;
  final String? storeName;
  final String? storeSlug;
  final String? weightInKg;
  final int? stockQuantity;
  final double? rating;
  final int? reviewCount;
  final List<String>? tags;
  final Map<String, dynamic>? attributes;
  final double? discountPercentage;
  final String? defaultVariantId;
  final List<ProductVariantEntity> variants;

  const ProductEntity({
    required this.id,
    required this.name,
    this.slug = '',
    this.basePrice,
    required this.price,
    this.compareAtPrice,
    this.discountEndDate,
    this.description,
    this.imageUrl,
    this.images,
    this.imagesList = const <ProductImageItem>[],
    this.category,
    this.categorySlug,
    this.brand,
    this.storeName,
    this.storeSlug,
    this.weightInKg,
    this.stockQuantity,
    this.rating,
    this.reviewCount,
    this.tags,
    this.attributes,
    this.discountPercentage,
    this.defaultVariantId,
    this.variants = const <ProductVariantEntity>[],
  });

  bool get hasDiscount =>
      price != null && compareAtPrice != null && compareAtPrice! > price!;

  bool get isOnSale {
    if (!hasDiscount) return false;
    if (discountEndDate == null) return true;
    final endDate = DateTime.tryParse(discountEndDate!);
    return endDate != null && endDate.isAfter(DateTime.now());
  }

  double? get discountAmount => hasDiscount ? compareAtPrice! - price! : null;

  double? get discountPercentageCalculated {
    if (!hasDiscount || compareAtPrice == null || compareAtPrice == 0) {
      return discountPercentage;
    }
    return ((compareAtPrice! - price!) / compareAtPrice!) * 100;
  }

  bool get isOutOfStock => stockQuantity != null && stockQuantity! <= 0;

  bool get isInStock => stockQuantity == null || stockQuantity! > 0;
}
