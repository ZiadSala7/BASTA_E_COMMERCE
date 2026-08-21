import '../../../../core/api/api_keys.dart';
import '../../domain/entities/home_product_entity.dart';

class HomeProductModel extends HomeProductEntity {
  const HomeProductModel({
    required super.id,
    super.slug = '',
    required super.name,
    required super.price,
    required super.compareAtPrice,
    required super.imageUrl,
    super.storeName,
    super.storeSlug,
  });

  factory HomeProductModel.fromJson(Map<String, dynamic> json) {
    return HomeProductModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      slug: (json['slug'] ?? '').toString(),
      name: (json['name'] ?? json['title'] ?? '').toString(),
      price: _numberFromJson(json['price']),
      compareAtPrice: _numberFromJson(json['compareAtPrice'] ?? json['compare_at_price'] ?? json['oldPrice']),
      imageUrl: _imageUrlFromJson(json),
      storeName: _nullableText(json['storeName'] ?? json['store_name']),
      storeSlug: _nullableText(json['storeSlug'] ?? json['store_slug']),
    );
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
}
