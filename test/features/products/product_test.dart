import 'package:busta/features/products/data/models/product_model.dart';
import 'package:busta/features/products/presentation/models/product_detail_args.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Product Integration according to FLUTTER_PRODUCT_DOCUMENTATION.md', () {
    test('ProductModel parses full product details by slug from backend JSON', () {
      final json = {
        "status": "success",
        "data": {
          "id": "e2298c40-3b91-49b9-8765-987654321fed",
          "name": "Handmade Artisan Fettuccine",
          "description": "Authentic Italian egg fettuccine made daily with durum semolina flour.",
          "basePrice": "24.99",
          "weightInKg": "0.500",
          "storeName": "La Pasta Bella",
          "storeSlug": "la-pasta-bella",
          "categoryName": "Fresh Pasta",
          "categorySlug": "fresh-pasta",
          "price": "24.99",
          "compareAtPrice": "29.99",
          "discountEndDate": "2026-12-31T23:59:59.000Z",
          "stockQuantity": 25,
          "sku": "FETT-500G",
          "defaultVariantId": "8f39b1a0-9c22-421d-b873-123456789abc",
          "variants": [
            {
              "id": "8f39b1a0-9c22-421d-b873-123456789abc",
              "productId": "e2298c40-3b91-49b9-8765-987654321fed",
              "attributes": { "size": "500g", "color": "#E53935" },
              "price": "24.99",
              "compareAtPrice": "29.99",
              "discountEndDate": "2026-12-31T23:59:59.000Z",
              "stockQuantity": 15,
              "sku": "FETT-500G",
              "imageId": "img-001"
            },
            {
              "id": "9a40c2b1-0d33-532e-c984-234567890def",
              "productId": "e2298c40-3b91-49b9-8765-987654321fed",
              "attributes": { "size": "1kg", "color": "#10B981" },
              "price": "44.99",
              "compareAtPrice": null,
              "discountEndDate": null,
              "stockQuantity": 10,
              "sku": "FETT-1KG"
            }
          ],
          "images": [
            {
              "id": "img-001",
              "imageUrl": "https://res.cloudinary.com/pasta/image/upload/v1/fettuccine-1.jpg",
              "orderIndex": 0
            },
            {
              "id": "img-002",
              "imageUrl": "https://res.cloudinary.com/pasta/image/upload/v1/fettuccine-2.jpg",
              "orderIndex": 1
            }
          ]
        }
      };

      final product = ProductModel.fromJson(json);

      expect(product.id, 'e2298c40-3b91-49b9-8765-987654321fed');
      expect(product.name, 'Handmade Artisan Fettuccine');
      expect(product.description, contains('Authentic Italian egg fettuccine'));
      expect(product.storeName, 'La Pasta Bella');
      expect(product.category, 'Fresh Pasta');
      expect(product.price, 24.99);
      expect(product.compareAtPrice, 29.99);
      expect(product.stockQuantity, 25);
      expect(product.defaultVariantId, '8f39b1a0-9c22-421d-b873-123456789abc');
      expect(product.variants.length, 2);
      expect(product.imagesList.length, 2);

      // Verify first variant
      final variant1 = product.variants[0];
      expect(variant1.id, '8f39b1a0-9c22-421d-b873-123456789abc');
      expect(variant1.size, '500g');
      expect(variant1.color, '#E53935');
      expect(variant1.price, 24.99);
      expect(variant1.stockQuantity, 15);
      expect(variant1.isOnSale, isTrue);
      expect(variant1.imageId, 'img-001');

      // Verify second variant
      final variant2 = product.variants[1];
      expect(variant2.id, '9a40c2b1-0d33-532e-c984-234567890def');
      expect(variant2.size, '1kg');
      expect(variant2.color, '#10B981');
      expect(variant2.price, 44.99);
      expect(variant2.stockQuantity, 10);
      expect(variant2.isOnSale, isFalse);
    });

    test('ProductDetailArgs variant search and gallery images matching', () {
      final json = {
        "id": "prod-1",
        "name": "Artisan Tagliatelle",
        "basePrice": "18.00",
        "price": "18.00",
        "compareAtPrice": "22.00",
        "variants": [
          {
            "id": "var-red-small",
            "attributes": {"size": "Small", "color": "#FF0000"},
            "price": "18.00",
            "stockQuantity": 8
          },
          {
            "id": "var-blue-large",
            "attributes": {"size": "Large", "color": "#0000FF"},
            "price": "28.00",
            "stockQuantity": 4
          }
        ],
        "images": [
          {"id": "img-1", "imageUrl": "https://example.com/img1.jpg", "orderIndex": 0},
          {"id": "img-2", "imageUrl": "https://example.com/img2.jpg", "orderIndex": 1}
        ]
      };

      final args = ProductDetailArgs.fromMap(json);

      expect(args.availableSizes, containsAll(['Small', 'Large']));
      expect(args.availableColors, containsAll(['#FF0000', '#0000FF']));
      expect(args.galleryImages.length, 2);

      final foundVariant = args.findVariant(size: 'Large', color: '#0000FF');
      expect(foundVariant?.id, 'var-blue-large');
      expect(foundVariant?.price, 28.00);
    });

    test('ProductDetailArgs resolves effectiveUnitPrice properly even without explicit unitPrice argument', () {
      const argsFromHome = ProductDetailArgs(
        id: 'prod-99',
        title: 'Fresh Ravioli',
        price: 'د.أ 15.50',
        oldPrice: 'د.أ 20.00',
      );

      expect(argsFromHome.effectiveUnitPrice, 15.50);
      expect(argsFromHome.effectiveCompareAtPrice, 20.00);
      expect(argsFromHome.hasDiscount, isTrue);
    });

    test('ProductModel fallback to variant price when root price is null', () {
      final json = {
        "id": "prod-100",
        "name": "Truffle Gnocchi",
        "variants": [
          {
            "id": "v-1",
            "price": "32.50",
            "compareAtPrice": "38.00",
            "stockQuantity": 5
          }
        ]
      };

      final product = ProductModel.fromJson(json);
      expect(product.price, 32.50);
      expect(product.compareAtPrice, 38.00);

      final args = ProductDetailArgs.fromEntity(product);
      expect(args.unitPrice, 32.50);
      expect(args.effectiveUnitPrice, 32.50);
    });
  });
}
