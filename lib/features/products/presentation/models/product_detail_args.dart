import '../../../../core/utils/currency_helper.dart';
import '../../data/models/product_model.dart';
import '../../domain/entities/product_entity.dart';

class ProductDetailArgs {
  final String id;
  final String title;
  final String slug;
  final String price;
  final double unitPrice;
  final String? oldPrice;
  final double? compareAtPrice;
  final String? discountEndDate;
  final String? imageUrl;
  final List<String>? images;
  final List<ProductImageItem> imagesList;
  final String? discountBadge;
  final double? rating;
  final int? reviewCount;
  final String? description;
  final String? category;
  final String? categorySlug;
  final String? brand;
  final String? storeName;
  final String? storeSlug;
  final String? weightInKg;
  final int? stockQuantity;
  final List<String>? tags;
  final Map<String, dynamic>? attributes;
  final double? discountPercentage;
  final String? defaultVariantId;
  final List<ProductVariantEntity> variants;

  const ProductDetailArgs({
    required this.id,
    required this.title,
    this.slug = '',
    required this.price,
    this.unitPrice = 0.0,
    this.oldPrice,
    this.compareAtPrice,
    this.discountEndDate,
    this.imageUrl,
    this.images,
    this.imagesList = const <ProductImageItem>[],
    this.discountBadge,
    this.rating,
    this.reviewCount,
    this.description,
    this.category,
    this.categorySlug,
    this.brand,
    this.storeName,
    this.storeSlug,
    this.weightInKg,
    this.stockQuantity,
    this.tags,
    this.attributes,
    this.discountPercentage,
    this.defaultVariantId,
    this.variants = const <ProductVariantEntity>[],
  });

  factory ProductDetailArgs.fromEntity(ProductEntity entity) {
    var priceNum = entity.price ?? 0.0;
    if (priceNum <= 0 && entity.basePrice != null && entity.basePrice! > 0) {
      priceNum = entity.basePrice!;
    }
    if (priceNum <= 0 && entity.variants.isNotEmpty) {
      for (final v in entity.variants) {
        if (v.price > 0) {
          priceNum = v.price;
          break;
        }
      }
    }

    var compareNum = entity.compareAtPrice;
    if (compareNum == null && entity.variants.isNotEmpty) {
      for (final v in entity.variants) {
        if (v.compareAtPrice != null && v.compareAtPrice! > priceNum) {
          compareNum = v.compareAtPrice;
          break;
        }
      }
    }

    final discountBadge = _calculateDiscountBadge(
      priceNum,
      compareNum,
      entity.discountPercentage,
    );

    return ProductDetailArgs(
      id: entity.id,
      title: entity.name,
      slug: entity.slug,
      price: priceNum > 0 ? 'JD ${priceNum.toStringAsFixed(2)}' : '',
      unitPrice: priceNum,
      oldPrice: compareNum != null && compareNum > priceNum
          ? 'JD ${compareNum.toStringAsFixed(2)}'
          : null,
      compareAtPrice: compareNum,
      discountEndDate: entity.discountEndDate,
      imageUrl: entity.imageUrl,
      images: entity.images,
      imagesList: entity.imagesList,
      discountBadge: discountBadge,
      rating: entity.rating,
      reviewCount: entity.reviewCount,
      description: entity.description,
      category: entity.category,
      categorySlug: entity.categorySlug,
      brand: entity.brand,
      storeName: entity.storeName,
      storeSlug: entity.storeSlug,
      weightInKg: entity.weightInKg,
      stockQuantity: entity.stockQuantity,
      tags: entity.tags,
      attributes: entity.attributes,
      discountPercentage: entity.discountPercentage,
      defaultVariantId: entity.defaultVariantId,
      variants: entity.variants,
    );
  }

  static List<ProductDetailArgs> fromEntityList(List<ProductEntity> entities) {
    return entities
        .map((entity) => ProductDetailArgs.fromEntity(entity))
        .toList();
  }

  factory ProductDetailArgs.fromMap(Map<String, dynamic> product) {
    final entity = ProductModel.fromJson(product);
    final directUnitPrice = (product['unitPrice'] is num)
        ? (product['unitPrice'] as num).toDouble()
        : (product['price'] is num
            ? (product['price'] as num).toDouble()
            : CurrencyHelper.parse(product['price']));

    final args = ProductDetailArgs.fromEntity(entity);
    if (args.unitPrice <= 0 && directUnitPrice > 0) {
      return args.copyWith(
        unitPrice: directUnitPrice,
        price: 'JD ${directUnitPrice.toStringAsFixed(2)}',
      );
    }
    return args;
  }

  factory ProductDetailArgs.fromProductModel(dynamic product) {
    if (product == null) {
      return const ProductDetailArgs(
        id: '',
        title: 'Product details',
        price: '',
      );
    }

    if (product is ProductDetailArgs) {
      return product;
    }

    if (product is ProductEntity) {
      return ProductDetailArgs.fromEntity(product);
    }

    if (product is Map<String, dynamic>) {
      return ProductDetailArgs.fromMap(product);
    }

    if (product is String) {
      return ProductDetailArgs.fallback(product);
    }

    return const ProductDetailArgs(id: '', title: 'Product details', price: '');
  }

  static String? _calculateDiscountBadge(
    double? price,
    double? compareAtPrice,
    double? discountPercentage,
  ) {
    if (discountPercentage != null && discountPercentage > 0) {
      return '-${discountPercentage.round()}%';
    }

    if (compareAtPrice != null && price != null && compareAtPrice > price) {
      final calculatedDiscount =
          ((compareAtPrice - price) / compareAtPrice) * 100;
      return '-${calculatedDiscount.round()}%';
    }

    return null;
  }

  factory ProductDetailArgs.fallback(String productId) {
    return ProductDetailArgs(
      id: productId,
      title: productId.isEmpty ? 'Product details' : 'Product #$productId',
      price: '',
    );
  }

  // Computed properties
  double get effectiveUnitPrice {
    if (unitPrice > 0) return unitPrice;
    final parsed = CurrencyHelper.parse(price);
    if (parsed > 0) return parsed;
    if (variants.isNotEmpty) {
      for (final v in variants) {
        if (v.price > 0) return v.price;
      }
    }
    return 0.0;
  }

  double? get effectiveCompareAtPrice {
    if (compareAtPrice != null && compareAtPrice! > 0) return compareAtPrice;
    final parsed = CurrencyHelper.parse(oldPrice);
    if (parsed > 0) return parsed;
    if (variants.isNotEmpty) {
      for (final v in variants) {
        if (v.compareAtPrice != null && v.compareAtPrice! > 0) {
          return v.compareAtPrice;
        }
      }
    }
    return null;
  }

  bool get hasDiscount =>
      effectiveCompareAtPrice != null &&
      effectiveUnitPrice > 0 &&
      effectiveCompareAtPrice! > effectiveUnitPrice;

  bool get isOnSale {
    if (!hasDiscount) return false;
    if (discountEndDate == null) return true;
    final endDate = DateTime.tryParse(discountEndDate!);
    return endDate != null && endDate.isAfter(DateTime.now());
  }

  bool get isOutOfStock => stockQuantity != null && stockQuantity! <= 0;

  bool get isInStock => stockQuantity == null || stockQuantity! > 0;

  List<String> get galleryImages {
    final ordered = <String>[
      if (imageUrl != null && imageUrl!.trim().isNotEmpty) imageUrl!,
      ...?images,
      ...imagesList.map((img) => img.imageUrl),
    ];

    return ordered
        .map((image) => image.trim())
        .where((image) => image.isNotEmpty)
        .toSet()
        .toList();
  }

  String get stockStatus {
    if (isOutOfStock) return 'Out of Stock';
    if (stockQuantity != null && stockQuantity! <= 5) return 'Low Stock';
    return 'In Stock';
  }

  ProductVariantEntity? get defaultVariant {
    if (variants.isEmpty) return null;
    if (defaultVariantId != null && defaultVariantId!.isNotEmpty) {
      for (final v in variants) {
        if (v.id == defaultVariantId) return v;
      }
    }
    return variants.first;
  }

  List<String> get availableSizes {
    final sizes = <String>{};
    for (final v in variants) {
      final s = v.size;
      if (s != null && s.trim().isNotEmpty) sizes.add(s.trim());
    }
    if (sizes.isEmpty && attributes != null) {
      final s = attributes!['size']?.toString() ?? attributes!['weight']?.toString();
      if (s != null && s.trim().isNotEmpty) sizes.add(s.trim());
    }
    return sizes.toList();
  }

  List<String> get availableColors {
    final colors = <String>{};
    for (final v in variants) {
      final c = v.color;
      if (c != null && c.trim().isNotEmpty) colors.add(c.trim());
    }
    if (colors.isEmpty && attributes != null) {
      final c = attributes!['color']?.toString();
      if (c != null && c.trim().isNotEmpty) colors.add(c.trim());
    }
    return colors.toList();
  }

  ProductVariantEntity? findVariant({String? size, String? color}) {
    if (variants.isEmpty) return null;

    // Try exact match
    for (final v in variants) {
      final matchesSize = size == null || size.isEmpty || v.size == size;
      final matchesColor = color == null || color.isEmpty || v.color == color;
      if (matchesSize && matchesColor) return v;
    }

    // Fallback: match size only
    if (size != null && size.isNotEmpty) {
      for (final v in variants) {
        if (v.size == size) return v;
      }
    }

    // Fallback: match color only
    if (color != null && color.isNotEmpty) {
      for (final v in variants) {
        if (v.color == color) return v;
      }
    }

    return defaultVariant;
  }

  ProductDetailArgs copyWith({
    String? id,
    String? title,
    String? slug,
    String? price,
    double? unitPrice,
    String? oldPrice,
    double? compareAtPrice,
    String? discountEndDate,
    String? imageUrl,
    List<String>? images,
    List<ProductImageItem>? imagesList,
    String? discountBadge,
    double? rating,
    int? reviewCount,
    String? description,
    String? category,
    String? categorySlug,
    String? brand,
    String? storeName,
    String? storeSlug,
    String? weightInKg,
    int? stockQuantity,
    List<String>? tags,
    Map<String, dynamic>? attributes,
    double? discountPercentage,
    String? defaultVariantId,
    List<ProductVariantEntity>? variants,
  }) {
    return ProductDetailArgs(
      id: id ?? this.id,
      title: title ?? this.title,
      slug: slug ?? this.slug,
      price: price ?? this.price,
      unitPrice: unitPrice ?? this.unitPrice,
      oldPrice: oldPrice ?? this.oldPrice,
      compareAtPrice: compareAtPrice ?? this.compareAtPrice,
      discountEndDate: discountEndDate ?? this.discountEndDate,
      imageUrl: imageUrl ?? this.imageUrl,
      images: images ?? this.images,
      imagesList: imagesList ?? this.imagesList,
      discountBadge: discountBadge ?? this.discountBadge,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      description: description ?? this.description,
      category: category ?? this.category,
      categorySlug: categorySlug ?? this.categorySlug,
      brand: brand ?? this.brand,
      storeName: storeName ?? this.storeName,
      storeSlug: storeSlug ?? this.storeSlug,
      weightInKg: weightInKg ?? this.weightInKg,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      tags: tags ?? this.tags,
      attributes: attributes ?? this.attributes,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      defaultVariantId: defaultVariantId ?? this.defaultVariantId,
      variants: variants ?? this.variants,
    );
  }
}
