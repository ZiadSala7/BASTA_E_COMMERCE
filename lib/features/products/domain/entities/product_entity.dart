class ProductEntity {
  final String id;
  final String name;
  final double? price;
  final double? compareAtPrice;
  final String? description;
  final String? imageUrl;
  final List<String>? images;
  final String? category;
  final String? brand;
  final int? stockQuantity;
  final double? rating;
  final int? reviewCount;
  final List<String>? tags;
  final Map<String, dynamic>? attributes;
  final double? discountPercentage;

  const ProductEntity({
    required this.id,
    required this.name,
    required this.price,
    this.compareAtPrice,
    this.description,
    this.imageUrl,
    this.images,
    this.category,
    this.brand,
    this.stockQuantity,
    this.rating,
    this.reviewCount,
    this.tags,
    this.attributes,
    this.discountPercentage,
  });

  bool get hasDiscount =>
      price != null && compareAtPrice != null && compareAtPrice! > price!;

  double? get discountAmount =>
      hasDiscount ? compareAtPrice! - price! : null;

  double? get discountPercentageCalculated {
    if (!hasDiscount || compareAtPrice == null || compareAtPrice == 0) {
      return discountPercentage;
    }
    return ((compareAtPrice! - price!) / compareAtPrice!) * 100;
  }

  bool get isOutOfStock => stockQuantity != null && stockQuantity! <= 0;

  bool get isInStock => stockQuantity == null || stockQuantity! > 0;
}