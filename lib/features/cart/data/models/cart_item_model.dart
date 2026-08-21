import '../../../../core/api/api_keys.dart';
import '../../domain/entities/cart_item_entity.dart';

class ProductImageModel extends ProductImageEntity {
  const ProductImageModel({
    required super.id,
    required super.productId,
    required super.imageUrl,
    required super.orderIndex,
  });

  factory ProductImageModel.fromJson(Map<String, dynamic> json) {
    return ProductImageModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      productId: (json['productId'] ?? json['product_id'] ?? '').toString(),
      imageUrl: _absoluteUrl(
        (json['imageUrl'] ??
                json['image_url'] ??
                json['url'] ??
                json['src'] ??
                '')
            .toString(),
      ),
      orderIndex:
          (json['orderIndex'] ?? json['order_index'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'imageUrl': imageUrl,
      'orderIndex': orderIndex,
    };
  }

  static String _absoluteUrl(String url) {
    if (url.isEmpty) return '';
    if (url.startsWith('http://') || url.startsWith('https://')) return url;

    final baseUrl = ApiKeys.baseUrl.endsWith('/')
        ? ApiKeys.baseUrl.substring(0, ApiKeys.baseUrl.length - 1)
        : ApiKeys.baseUrl;
    final path = url.startsWith('/') ? url : '/$url';
    return '$baseUrl$path';
  }
}

class CartItemModel extends CartItemEntity {
  const CartItemModel({
    required super.id,
    super.cartItemId = '',
    super.variantId = '',
    super.productId = '',
    required super.name,
    super.slug = '',
    required super.price,
    super.activePrice,
    super.compareAtPrice,
    super.discountEndDate,
    required super.quantity,
    super.stockQuantity = 0,
    super.sku,
    super.variantImageId,
    super.isSaleActive = false,
    super.storeId,
    required super.storeName,
    super.storeSlug,
    super.weightInKg,
    super.attributes,
    super.color,
    super.size,
    required super.imageUrl,
    super.images = const <ProductImageModel>[],
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

    final cartItemId = _firstText([
      json['cartItemId'],
      json['cart_item_id'],
      json['id'],
      json['_id'],
    ]);

    final variantId = _firstText([
      json['variantId'],
      json['variant_id'],
      json['variant'],
    ]);

    final productId = _firstText([
      json['productId'],
      json['product_id'],
      product['id'],
      product['_id'],
      json['product'],
    ]);

    final primaryId = cartItemId.isNotEmpty
        ? cartItemId
        : (variantId.isNotEmpty ? variantId : productId);

    final rawImages = json['images'] ?? product['images'];
    final imagesList = <ProductImageModel>[];
    if (rawImages is List) {
      for (final img in rawImages) {
        if (img is Map) {
          imagesList.add(
            ProductImageModel.fromJson(Map<String, dynamic>.from(img)),
          );
        } else if (img is String && img.isNotEmpty) {
          imagesList.add(
            ProductImageModel(
              id: '',
              productId: productId,
              imageUrl: ProductImageModel._absoluteUrl(img),
              orderIndex: imagesList.length,
            ),
          );
        }
      }
    }

    final attributes = json['attributes'] is Map
        ? Map<String, dynamic>.from(json['attributes'] as Map)
        : (product['attributes'] is Map
            ? Map<String, dynamic>.from(product['attributes'] as Map)
            : null);

    final color = _nullableText(
      json['color'] ?? attributes?['color'] ?? attributes?['Color'],
    );
    final size = _nullableText(
      json['size'] ??
          attributes?['size'] ??
          attributes?['Size'] ??
          attributes?['weight'] ??
          attributes?['type'],
    );

    final imageUrl = _extractImageUrl(json, product, imagesList);

    final rawPrice = json['price'] ??
        json['unitPrice'] ??
        json['unit_price'] ??
        product['price'];
    final rawActivePrice = json['activePrice'] ??
        json['active_price'] ??
        json['salePrice'] ??
        json['sale_price'] ??
        product['activePrice'] ??
        product['active_price'] ??
        rawPrice;

    final price = _number(rawPrice);
    final activePrice = _number(rawActivePrice);

    return CartItemModel(
      id: primaryId,
      cartItemId: cartItemId,
      variantId: variantId,
      productId: productId,
      name: _firstText([
        json['productName'],
        json['product_name'],
        json['name'],
        json['title'],
        json['productTitle'],
        json['product_title'],
        product['name'],
        product['title'],
        product['productName'],
        product['product_name'],
      ], fallback: productId.isEmpty ? 'Product' : 'Product #$productId'),
      slug: _firstText([json['slug'], product['slug']]),
      price: price,
      activePrice: activePrice > 0 ? activePrice : price,
      compareAtPrice: _nullableNumber(
        json['compareAtPrice'] ??
            json['compare_at_price'] ??
            product['compareAtPrice'],
      ),
      discountEndDate: _nullableText(
        json['discountEndDate'] ??
            json['discount_end_date'] ??
            product['discountEndDate'],
      ),
      quantity: _int(json['quantity'], fallback: 1),
      stockQuantity: _int(
        json['stockQuantity'] ??
            json['stock_quantity'] ??
            product['stockQuantity'] ??
            product['stock_quantity'],
        fallback: 0,
      ),
      sku: _nullableText(json['sku'] ?? product['sku']),
      variantImageId: _nullableText(
        json['variantImageId'] ??
            json['variant_image_id'] ??
            product['variantImageId'],
      ),
      isSaleActive: json['isSaleActive'] == true ||
          json['is_sale_active'] == true ||
          product['isSaleActive'] == true,
      storeId: _nullableText(
        json['storeId'] ??
            json['store_id'] ??
            store['id'] ??
            store['_id'] ??
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
        json['storeSlug'] ??
            json['store_slug'] ??
            store['slug'] ??
            product['storeSlug'] ??
            product['store_slug'],
      ),
      weightInKg: _nullableText(
        json['weightInKg'] ?? json['weight_in_kg'] ?? product['weightInKg'],
      ),
      attributes: attributes,
      color: color,
      size: size,
      imageUrl: imageUrl,
      images: imagesList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cartItemId': cartItemId,
      'variantId': variantId,
      'productId': productId,
      'quantity': quantity,
      'productName': name,
      'slug': slug,
      'storeId': storeId,
      'storeName': storeName,
      'storeSlug': storeSlug,
      'weightInKg': weightInKg,
      'attributes': attributes,
      'price': price.toStringAsFixed(2),
      'compareAtPrice': compareAtPrice?.toStringAsFixed(2),
      'discountEndDate': discountEndDate,
      'stockQuantity': stockQuantity,
      'sku': sku,
      'variantImageId': variantImageId,
      'activePrice': activePrice.toStringAsFixed(2),
      'isSaleActive': isSaleActive,
      'imageUrl': imageUrl,
      'images': images
          .map(
            (img) => ProductImageModel(
              id: img.id,
              productId: img.productId,
              imageUrl: img.imageUrl,
              orderIndex: img.orderIndex,
            ).toJson(),
          )
          .toList(),
    };
  }

  static Map<String, dynamic> _asMap(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, item) => MapEntry(key.toString(), item));
    }
    return <String, dynamic>{};
  }

  static String _text(Object? value) => (value ?? '').toString().trim();

  static String _firstText(List<Object?> values, {String fallback = ''}) {
    for (final value in values) {
      if (value == null || value is Map || value is List) continue;

      final text = value.toString().trim();
      if (text.isNotEmpty) return text;
    }

    return fallback;
  }

  static String? _nullableText(Object? value) {
    if (value == null || value is Map || value is List) return null;

    final text = _text(value);
    return text.isEmpty ? null : text;
  }

  static double _number(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse((value ?? '').toString().trim()) ?? 0.0;
  }

  static double? _nullableNumber(Object? value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString().trim());
  }

  static int _int(Object? value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse((value ?? '').toString().trim()) ?? fallback;
  }

  static String _extractImageUrl(
    Map<String, dynamic> json,
    Map<String, dynamic> product,
    List<ProductImageModel> imagesList,
  ) {
    final variantImageId =
        json['variantImageId'] ?? json['variant_image_id'];
    if (variantImageId != null && imagesList.isNotEmpty) {
      for (final img in imagesList) {
        if (img.id == variantImageId.toString() && img.imageUrl.isNotEmpty) {
          return img.imageUrl;
        }
      }
    }

    if (imagesList.isNotEmpty && imagesList.first.imageUrl.isNotEmpty) {
      return imagesList.first.imageUrl;
    }

    final direct =
        json['imageUrl'] ??
        json['image_url'] ??
        json['image'] ??
        json['thumbnail'] ??
        product['imageUrl'] ??
        product['image_url'] ??
        product['image'] ??
        product['thumbnail'];

    if (direct != null && direct.toString().trim().isNotEmpty) {
      return ProductImageModel._absoluteUrl(direct.toString().trim());
    }

    return '';
  }
}
