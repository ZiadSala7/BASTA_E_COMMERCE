import '../../../../core/api/api_keys.dart';
import '../../domain/entities/cart_item_entity.dart';

class CartItemModel extends CartItemEntity {
  const CartItemModel({
    required super.id,
    required super.productId,
    required super.name,
    required super.price,
    required super.activePrice,
    required super.quantity,
    super.storeId,
    required super.storeName,
    super.storeSlug,
    required super.imageUrl,
    super.color,
    super.size,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    final rawProduct =
        json['product'] ?? json['productId'] ?? json['product_id'];
    final product = _asMap(rawProduct);
    final rawStore =
        product['store'] ??
        product['storeId'] ??
        product['store_id'] ??
        json['store'] ??
        json['storeId'] ??
        json['store_id'];
    final store = _asMap(rawStore);
    final productId = _firstText([
      product['id'],
      product['_id'],
      json['productId'],
      json['product_id'],
      json['product'],
    ]);

    return CartItemModel(
      id: _text(json['id'] ?? json['_id'] ?? json['cartItemId'] ?? productId),
      productId: productId,
      name: _firstText([
        json['name'],
        json['title'],
        json['productName'],
        json['product_name'],
        json['productTitle'],
        json['product_title'],
        product['name'],
        product['title'],
        product['productName'],
        product['product_name'],
      ], fallback: productId.isEmpty ? 'Product' : 'Product #$productId'),
      price: _number(
        json['price'] ??
            json['unitPrice'] ??
            json['unit_price'] ??
            product['price'],
      ),
      activePrice: _number(
        json['activePrice'] ??
            json['active_price'] ??
            json['salePrice'] ??
            json['sale_price'] ??
            json['price'] ??
            json['unitPrice'] ??
            json['unit_price'] ??
            product['activePrice'] ??
            product['active_price'] ??
            product['price'],
      ),
      quantity: _int(json['quantity'], fallback: 1),
      storeId: _nullableText(
        store['id'] ??
            store['_id'] ??
            json['storeId'] ??
            json['store_id'] ??
            product['storeId'] ??
            product['store_id'],
      ),
      storeName: _firstText([
        json['storeName'],
        json['store_name'],
        store['name'] ?? store['title'],
        product['storeName'],
        product['store_name'],
      ]),
      storeSlug: _nullableText(
        store['slug'] ??
            json['storeSlug'] ??
            json['store_slug'] ??
            product['storeSlug'] ??
            product['store_slug'],
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

  static String _firstText(List<Object?> values, {String fallback = ''}) {
    for (final value in values) {
      if (value == null || value is Map || value is List) continue;

      final text = value.toString().trim();
      if (text.isNotEmpty) return text;
    }

    return fallback;
  }

  static String? _nullableText(Object? value) {
    if (value is Map || value is List) return null;

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
