import '../../../../core/api/api_keys.dart';
import '../../data/models/product_model.dart';
import '../../domain/entities/product_entity.dart';

class ProductDetailArgs {
  final String id;
  final String title;
  final String price;
  final String? oldPrice;
  final String? imageUrl;
  final List<String>? images;
  final String? discountBadge;
  final double? rating;
  final int? reviewCount;
  final String? description;
  final String? category;
  final String? brand;
  final int? stockQuantity;
  final List<String>? tags;
  final Map<String, dynamic>? attributes;
  final double? discountPercentage;

  const ProductDetailArgs({
    required this.id,
    required this.title,
    required this.price,
    this.oldPrice,
    this.imageUrl,
    this.images,
    this.discountBadge,
    this.rating,
    this.reviewCount,
    this.description,
    this.category,
    this.brand,
    this.stockQuantity,
    this.tags,
    this.attributes,
    this.discountPercentage,
  });

  // Factory constructor from ProductEntity
  factory ProductDetailArgs.fromEntity(ProductEntity entity) {
    final discountBadge = _calculateDiscountBadge(
      entity.price,
      entity.compareAtPrice,
      entity.discountPercentage,
    );

    return ProductDetailArgs(
      id: entity.id,
      title: entity.name,
      price: entity.price != null
          ? 'JD ${entity.price!.toStringAsFixed(2)}'
          : '',
      oldPrice: entity.compareAtPrice != null
          ? 'JD ${entity.compareAtPrice!.toStringAsFixed(2)}'
          : null,
      imageUrl: entity.imageUrl,
      images: entity.images,
      discountBadge: discountBadge,
      rating: entity.rating,
      reviewCount: entity.reviewCount,
      description: entity.description,
      category: entity.category,
      brand: entity.brand,
      stockQuantity: entity.stockQuantity,
      tags: entity.tags,
      attributes: entity.attributes,
      discountPercentage: entity.discountPercentage,
    );
  }

  /// Creates a list of ProductDetailArgs from a list of ProductEntity objects
  static List<ProductDetailArgs> fromEntityList(List<ProductEntity> entities) {
    return entities
        .map((entity) => ProductDetailArgs.fromEntity(entity))
        .toList();
  }

  /// Creates a list of ProductDetailArgs from API response data
  static List<ProductDetailArgs> fromApiResponse(List<dynamic> apiData) {
    return apiData
        .where((item) => item != null)
        .map((item) {
          if (item is ProductEntity) {
            return ProductDetailArgs.fromEntity(item);
          } else if (item is ProductModel) {
            return ProductDetailArgs.fromEntity(item);
          } else if (item is Map<String, dynamic>) {
            return ProductDetailArgs.fromMap(item);
          }
          return null;
        })
        .where((args) => args != null)
        .cast<ProductDetailArgs>()
        .toList();
  }

  factory ProductDetailArgs.fromMap(Map<String, dynamic> product) {
    final rating = product['rating'];
    final price = _numberFromJson(product['price']);
    final compareAtPrice = _numberFromJson(
      product['compareAtPrice'] ?? product['oldPrice'] ?? product['old_price'],
    );
    final discountPercentage = _numberFromJson(
      product['discountPercentage'] ?? product['discount_percentage'],
    );

    // Calculate discount badge using the new helper method
    final discountBadge = _calculateDiscountBadge(
      price,
      compareAtPrice,
      discountPercentage,
    );

    return ProductDetailArgs(
      id: (product['id'] ?? '').toString(),
      title: (product['title'] ?? product['name'] ?? '').toString(),
      price: price != null ? 'JD ${price.toStringAsFixed(2)}' : '',
      oldPrice: compareAtPrice != null
          ? 'JD ${compareAtPrice.toStringAsFixed(2)}'
          : null,
      imageUrl: _imageUrlFromJson(product),
      images: _extractImages(product),
      discountBadge: discountBadge,
      rating: rating is num ? rating.toDouble() : double.tryParse('$rating'),
      reviewCount: int.tryParse(
        (product['reviews'] ??
                product['reviewCount'] ??
                product['review_count'] ??
                '')
            .toString(),
      ),
      description: product['description']?.toString(),
      category: _nameFromJson(product['category']),
      brand: _nameFromJson(product['brand']),
      stockQuantity: _numberFromJson(
        product['stockQuantity'] ?? product['stock_quantity'],
      )?.toInt(),
      tags: _extractTags(product),
      attributes: _extractAttributes(product),
      discountPercentage: discountPercentage,
    );
  }

  factory ProductDetailArgs.fromProductModel(dynamic product) {
    if (product == null) {
      return const ProductDetailArgs(
        id: '',
        title: 'Product details',
        price: '',
      );
    }

    // Handle if it's already a ProductDetailArgs
    if (product is ProductDetailArgs) {
      return product;
    }

    // Handle if it's a ProductEntity (from API)
    if (product is ProductEntity) {
      return ProductDetailArgs.fromEntity(product);
    }

    // Handle if it's a ProductModel (from API)
    if (product is ProductModel) {
      return ProductDetailArgs.fromEntity(product);
    }

    // Handle if it's a Map
    if (product is Map<String, dynamic>) {
      return ProductDetailArgs.fromMap(product);
    }

    // Handle if it's a string (product ID)
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
    if (discountPercentage != null) {
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

  static double? _numberFromJson(Object? value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static String _imageUrlFromJson(Map<String, dynamic> json) {
    final directUrl = (json['image_url'] ?? json['imageUrl'] ?? json['image'])
        ?.toString();
    if (directUrl != null && directUrl.isNotEmpty) {
      return _absoluteUrl(directUrl);
    }

    final images = json['images'];
    if (images is List && images.isNotEmpty) {
      final firstImage = images.whereType<Map>().firstOrNull;
      final imageUrl =
          firstImage?['url']?.toString() ?? firstImage?['imageUrl']?.toString();
      if (imageUrl != null && imageUrl.isNotEmpty) {
        return _absoluteUrl(imageUrl);
      }
    }

    return '';
  }

  static List<String>? _extractImages(Map<String, dynamic> json) {
    final images = json['images'];
    if (images is List) {
      return images
          .map((img) {
            final url = img is Map
                ? (img['url'] ?? img['imageUrl'] ?? img['image_url'])
                      ?.toString()
                : img.toString();
            return url != null && url.isNotEmpty ? _absoluteUrl(url) : '';
          })
          .where((url) => url.isNotEmpty)
          .toList();
    }

    return null;
  }

  static List<String>? _extractTags(Map<String, dynamic> json) {
    final tags = json['tags'];
    if (tags is List) {
      return tags.whereType<String>().toList();
    }
    if (tags is String) {
      return tags.split(',').map((tag) => tag.trim()).toList();
    }
    return null;
  }

  static Map<String, dynamic>? _extractAttributes(Map<String, dynamic> json) {
    final attributes =
        json['attributes'] ?? json['specs'] ?? json['specifications'];
    if (attributes is Map) {
      return Map<String, dynamic>.from(attributes);
    }
    return null;
  }

  static String? _nameFromJson(Object? value) {
    if (value == null) return null;
    if (value is Map) {
      final name = value['name'] ?? value['title'] ?? value['slug'];
      return name?.toString();
    }
    return value.toString();
  }

  static String _absoluteUrl(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) return url;

    // Use the same logic as ProductModel to ensure consistency
    final baseUrl = ApiKeys.baseUrl.endsWith('/')
        ? ApiKeys.baseUrl.substring(0, ApiKeys.baseUrl.length - 1)
        : ApiKeys.baseUrl;
    final path = url.startsWith('/') ? url : '/$url';
    return '$baseUrl$path';
  }

  // Computed properties
  bool get hasDiscount =>
      price.isNotEmpty && oldPrice != null && oldPrice!.isNotEmpty;

  bool get isOutOfStock => stockQuantity != null && stockQuantity! <= 0;

  bool get isInStock => stockQuantity == null || stockQuantity! > 0;

  List<String> get galleryImages {
    final ordered = <String>[
      if (imageUrl != null && imageUrl!.trim().isNotEmpty) imageUrl!,
      ...?images,
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
}
