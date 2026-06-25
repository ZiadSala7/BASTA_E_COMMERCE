import '../../../../core/api/api_keys.dart';
import '../../domain/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.name,
    required super.price,
    super.compareAtPrice,
    super.description,
    super.imageUrl,
    super.images,
    super.category,
    super.brand,
    super.storeName,
    super.storeSlug,
    super.stockQuantity,
    super.rating,
    super.reviewCount,
    super.tags,
    super.attributes,
    super.discountPercentage,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? json['title'] ?? '').toString(),
      price: _numberFromJson(json['price']),
      compareAtPrice: _numberFromJson(
        json['compareAtPrice'] ?? json['compare_at_price'],
      ),
      description: json['description']?.toString(),
      imageUrl: _imageUrlFromJson(json),
      images: _extractImages(json),
      category: _nameFromJson(json['category']),
      brand: _nameFromJson(json['brand']),
      storeName: _nullableText(json['storeName'] ?? json['store_name']),
      storeSlug: _nullableText(json['storeSlug'] ?? json['store_slug']),
      stockQuantity: _numberFromJson(
        json['stockQuantity'] ?? json['stock_quantity'],
      )?.toInt(),
      rating: _numberFromJson(json['rating']),
      reviewCount: _numberFromJson(
        json['reviewCount'] ?? json['review_count'],
      )?.toInt(),
      tags: _extractTags(json),
      attributes: _extractAttributes(json),
      discountPercentage: _numberFromJson(
        json['discountPercentage'] ?? json['discount_percentage'],
      ),
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

  static String? _nullableText(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  static String _absoluteUrl(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) return url;

    final baseUrl = ApiKeys.baseUrl.endsWith('/')
        ? ApiKeys.baseUrl.substring(0, ApiKeys.baseUrl.length - 1)
        : ApiKeys.baseUrl;
    final path = url.startsWith('/') ? url : '/$url';
    return '$baseUrl$path';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'compareAtPrice': compareAtPrice,
      'description': description,
      'imageUrl': imageUrl,
      'images': images,
      'category': category,
      'brand': brand,
      'storeName': storeName,
      'storeSlug': storeSlug,
      'stockQuantity': stockQuantity,
      'rating': rating,
      'reviewCount': reviewCount,
      'tags': tags,
      'attributes': attributes,
      'discountPercentage': discountPercentage,
    };
  }
}
