import '../../../../core/api/api_keys.dart';
import '../../domain/entities/product_entity.dart';

class ProductVariantModel extends ProductVariantEntity {
  const ProductVariantModel({
    required super.id,
    super.productId,
    required super.attributes,
    required super.price,
    super.compareAtPrice,
    super.discountEndDate,
    required super.stockQuantity,
    super.sku,
    super.imageId,
  });

  factory ProductVariantModel.fromJson(Map<String, dynamic> json) {
    final rawAttributes = json['attributes'] ?? json['specs'];
    final attributes = rawAttributes is Map
        ? Map<String, dynamic>.from(rawAttributes)
        : <String, dynamic>{};

    // If size/color are top level fields, also populate them in attributes
    if (json['size'] != null && !attributes.containsKey('size')) {
      attributes['size'] = json['size'];
    }
    if (json['color'] != null && !attributes.containsKey('color')) {
      attributes['color'] = json['color'];
    }

    final rawPrice = json['price'] ?? json['unitPrice'] ?? json['unit_price'];
    final price = _numberFromJson(rawPrice) ?? 0.0;

    return ProductVariantModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      productId: json['productId']?.toString() ?? json['product_id']?.toString(),
      attributes: attributes,
      price: price,
      compareAtPrice: _numberFromJson(
        json['compareAtPrice'] ?? json['compare_at_price'] ?? json['oldPrice'],
      ),
      discountEndDate: json['discountEndDate']?.toString() ??
          json['discount_end_date']?.toString(),
      stockQuantity: _numberFromJson(
        json['stockQuantity'] ?? json['stock_quantity'],
      )?.toInt() ?? 0,
      sku: json['sku']?.toString(),
      imageId: json['imageId']?.toString() ?? json['image_id']?.toString() ?? json['variantImageId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'attributes': attributes,
      'price': price.toStringAsFixed(2),
      'compareAtPrice': compareAtPrice?.toStringAsFixed(2),
      'discountEndDate': discountEndDate,
      'stockQuantity': stockQuantity,
      'sku': sku,
      'imageId': imageId,
    };
  }

  static double? _numberFromJson(Object? value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString().trim());
  }
}

class ProductImageModel extends ProductImageItem {
  const ProductImageModel({
    required super.id,
    super.productId,
    required super.imageUrl,
    required super.orderIndex,
  });

  factory ProductImageModel.fromJson(Map<String, dynamic> json) {
    final rawUrl = json['imageUrl'] ??
        json['image_url'] ??
        json['url'] ??
        json['src'] ??
        json['image'];

    return ProductImageModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      productId: json['productId']?.toString() ?? json['product_id']?.toString(),
      imageUrl: _absoluteUrl((rawUrl ?? '').toString()),
      orderIndex: (json['orderIndex'] ?? json['order_index'] as num?)?.toInt() ?? 0,
    );
  }

  static String _absoluteUrl(String url) {
    final cleanUrl = url.trim();
    if (cleanUrl.isEmpty) return '';
    if (cleanUrl.startsWith('http://') || cleanUrl.startsWith('https://')) {
      return cleanUrl;
    }

    final baseUrl = ApiKeys.baseUrl.endsWith('/')
        ? ApiKeys.baseUrl.substring(0, ApiKeys.baseUrl.length - 1)
        : ApiKeys.baseUrl;
    final path = cleanUrl.startsWith('/') ? cleanUrl : '/$cleanUrl';
    return '$baseUrl$path';
  }
}

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.name,
    super.slug = '',
    super.basePrice,
    required super.price,
    super.compareAtPrice,
    super.discountEndDate,
    super.description,
    super.imageUrl,
    super.images,
    super.imagesList = const <ProductImageModel>[],
    super.category,
    super.categorySlug,
    super.brand,
    super.storeName,
    super.storeSlug,
    super.weightInKg,
    super.stockQuantity,
    super.rating,
    super.reviewCount,
    super.tags,
    super.attributes,
    super.discountPercentage,
    super.defaultVariantId,
    super.variants = const <ProductVariantModel>[],
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'] ?? json['product'] ?? json['item'];
    var payload = rawData is Map<String, dynamic>
        ? rawData
        : (rawData is Map ? Map<String, dynamic>.from(rawData) : json);

    if (payload['product'] is Map) {
      payload = Map<String, dynamic>.from(payload['product']);
    }

    final rawVariants = payload['variants'] ?? payload['productVariants'];
    final variantsList = <ProductVariantModel>[];
    if (rawVariants is List) {
      for (final v in rawVariants) {
        if (v is Map) {
          variantsList.add(
            ProductVariantModel.fromJson(Map<String, dynamic>.from(v)),
          );
        }
      }
    }

    final rawImages = payload['images'];
    final imagesModelList = <ProductImageModel>[];
    final stringImages = <String>[];

    if (rawImages is List) {
      for (var i = 0; i < rawImages.length; i++) {
        final img = rawImages[i];
        if (img is Map) {
          final model = ProductImageModel.fromJson(Map<String, dynamic>.from(img));
          if (model.imageUrl.isNotEmpty) {
            imagesModelList.add(model);
            stringImages.add(model.imageUrl);
          }
        } else if (img is String && img.trim().isNotEmpty) {
          final absoluteUrl = ProductImageModel._absoluteUrl(img);
          imagesModelList.add(
            ProductImageModel(
              id: 'img-$i',
              imageUrl: absoluteUrl,
              orderIndex: i,
            ),
          );
          stringImages.add(absoluteUrl);
        }
      }
    }

    var price = _numberFromJson(
      payload['price'] ??
          payload['activePrice'] ??
          payload['basePrice'] ??
          payload['unitPrice'] ??
          payload['unit_price'] ??
          payload['finalPrice'] ??
          payload['discountPrice'],
    );
    final basePrice = _numberFromJson(
      payload['basePrice'] ?? payload['base_price'] ?? payload['price'],
    );
    var compareAtPrice = _numberFromJson(
      payload['compareAtPrice'] ??
          payload['compare_at_price'] ??
          payload['oldPrice'] ??
          payload['originalPrice'],
    );

    // Fallback: If price is null or <= 0, extract from variants
    if ((price == null || price <= 0) && variantsList.isNotEmpty) {
      for (final v in variantsList) {
        if (v.price > 0) {
          price = v.price;
          break;
        }
      }
    }

    // Fallback: If compareAtPrice is null, extract from variants
    if (compareAtPrice == null && variantsList.isNotEmpty) {
      for (final v in variantsList) {
        if (v.compareAtPrice != null && v.compareAtPrice! > (price ?? 0)) {
          compareAtPrice = v.compareAtPrice;
          break;
        }
      }
    }

    final directImageUrl = _imageUrlFromJson(payload, imagesModelList);
    if (directImageUrl.isNotEmpty && !stringImages.contains(directImageUrl)) {
      stringImages.insert(0, directImageUrl);
    }

    return ProductModel(
      id: (payload['id'] ?? payload['_id'] ?? '').toString(),
      name: (payload['name'] ?? payload['title'] ?? payload['productName'] ?? '').toString(),
      slug: (payload['slug'] ?? '').toString(),
      basePrice: basePrice,
      price: price ?? basePrice ?? 0.0,
      compareAtPrice: compareAtPrice,
      discountEndDate: payload['discountEndDate']?.toString() ?? payload['discount_end_date']?.toString(),
      description: payload['description']?.toString(),
      imageUrl: directImageUrl,
      images: stringImages.isNotEmpty ? stringImages : null,
      imagesList: imagesModelList,
      category: _nameFromJson(payload['category']) ?? payload['categoryName']?.toString(),
      categorySlug: payload['categorySlug']?.toString() ?? (payload['category'] is Map ? payload['category']['slug']?.toString() : null),
      brand: _nameFromJson(payload['brand']),
      storeName: _nullableText(payload['storeName'] ?? payload['store_name'] ?? (payload['store'] is Map ? payload['store']['name'] : null)),
      storeSlug: _nullableText(payload['storeSlug'] ?? payload['store_slug'] ?? (payload['store'] is Map ? payload['store']['slug'] : null)),
      weightInKg: payload['weightInKg']?.toString() ?? payload['weight_in_kg']?.toString(),
      stockQuantity: _numberFromJson(
        payload['stockQuantity'] ?? payload['stock_quantity'],
      )?.toInt(),
      rating: _numberFromJson(payload['rating'] ?? payload['averageRating']),
      reviewCount: _numberFromJson(
        payload['reviewCount'] ?? payload['review_count'] ?? payload['reviews'],
      )?.toInt(),
      tags: _extractTags(payload),
      attributes: _extractAttributes(payload),
      discountPercentage: _numberFromJson(
        payload['discountPercentage'] ?? payload['discount_percentage'],
      ),
      defaultVariantId: payload['defaultVariantId']?.toString() ?? payload['default_variant_id']?.toString(),
      variants: variantsList,
    );
  }

  static double? _numberFromJson(Object? value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString().trim());
  }

  static String _imageUrlFromJson(
    Map<String, dynamic> json,
    List<ProductImageModel> imagesList,
  ) {
    final directUrl = (json['image_url'] ?? json['imageUrl'] ?? json['image'])
        ?.toString();
    if (directUrl != null && directUrl.trim().isNotEmpty) {
      return ProductImageModel._absoluteUrl(directUrl);
    }

    if (imagesList.isNotEmpty) {
      return imagesList.first.imageUrl;
    }

    return '';
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'basePrice': basePrice?.toStringAsFixed(2),
      'price': price?.toStringAsFixed(2),
      'compareAtPrice': compareAtPrice?.toStringAsFixed(2),
      'discountEndDate': discountEndDate,
      'description': description,
      'imageUrl': imageUrl,
      'images': images,
      'category': category,
      'categorySlug': categorySlug,
      'brand': brand,
      'storeName': storeName,
      'storeSlug': storeSlug,
      'weightInKg': weightInKg,
      'stockQuantity': stockQuantity,
      'rating': rating,
      'reviewCount': reviewCount,
      'tags': tags,
      'attributes': attributes,
      'discountPercentage': discountPercentage,
      'defaultVariantId': defaultVariantId,
      'variants': variants
          .map((v) => (v is ProductVariantModel) ? v.toJson() : null)
          .whereType<Map<String, dynamic>>()
          .toList(),
    };
  }
}
