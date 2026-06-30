part of '../home_featured_products_section.dart';

class HomeFeaturedProduct {
  final String id;
  final String title;
  final String price;
  final String? oldPrice;
  final String imageUrl;
  final String? imageAsset;
  final String? storeName;
  final String? storeSlug;
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
    this.storeName,
    this.storeSlug,
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
      storeName: _nullableText(json['storeName'] ?? json['store_name']),
      storeSlug: _nullableText(json['storeSlug'] ?? json['store_slug']),
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

  static String? _nullableText(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
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
