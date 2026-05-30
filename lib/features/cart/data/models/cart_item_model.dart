import '../../../../core/api/api_keys.dart';
import '../../domain/entities/cart_item_entity.dart';

class CartItemModel extends CartItemEntity {
  const CartItemModel({
    required super.id,
    required super.productId,
    required super.name,
    required super.price,
    required super.quantity,
    required super.storeName,
    required super.imageUrl,
    super.color,
    super.size,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    final rawProduct = json['product'];
    final product = _asMap(rawProduct);
    final store = _asMap(product['store'] ?? json['store']);
    final productId = _text(
      json['productId'] ??
          json['product_id'] ??
          (rawProduct is Map ? null : rawProduct) ??
          product['id'] ??
          product['_id'],
    );

    return CartItemModel(
      id: _text(json['id'] ?? json['_id'] ?? json['cartItemId'] ?? productId),
      productId: productId,
      name: _text(
        json['name'] ?? json['title'] ?? product['name'] ?? product['title'],
      ),
      price: _number(
        json['price'] ??
            json['unitPrice'] ??
            json['unit_price'] ??
            product['price'],
      ),
      quantity: _int(json['quantity'], fallback: 1),
      storeName: _text(
        json['storeName'] ?? store['name'] ?? product['storeName'],
      ),
      color: _nullableText(json['color']),
      size: _nullableText(json['size']),
      imageUrl: _imageUrl(json, product),
    );
  }

  static Map<String, dynamic> _asMap(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, item) => MapEntry(key.toString(), item));
    }
    return <String, dynamic>{};
  }

  static String _text(Object? value) => (value ?? '').toString();

  static String? _nullableText(Object? value) {
    final text = _text(value);
    return text.isEmpty ? null : text;
  }

  static double _number(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse((value ?? '').toString()) ?? 0;
  }

  static int _int(Object? value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse((value ?? '').toString()) ?? fallback;
  }

  static String _imageUrl(
    Map<String, dynamic> item,
    Map<String, dynamic> product,
  ) {
    final direct =
        item['imageUrl'] ??
        item['image_url'] ??
        item['image'] ??
        item['thumbnail'] ??
        product['imageUrl'] ??
        product['image_url'] ??
        product['image'] ??
        product['thumbnail'];
    if (direct != null && direct.toString().isNotEmpty) {
      return _absoluteUrl(direct.toString());
    }

    final images = item['images'] ?? product['images'];
    if (images is List && images.isNotEmpty) {
      final firstImage = images.first;
      if (firstImage is Map) {
        final url =
            firstImage['imageUrl'] ??
            firstImage['image_url'] ??
            firstImage['url'] ??
            firstImage['src'];
        if (url != null && url.toString().isNotEmpty) {
          return _absoluteUrl(url.toString());
        }
      }

      if (firstImage is String && firstImage.isNotEmpty) {
        return _absoluteUrl(firstImage);
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
