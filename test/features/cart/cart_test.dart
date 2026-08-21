import 'package:busta/features/cart/data/models/cart_coupon_model.dart';
import 'package:busta/features/cart/data/models/cart_data_model.dart';
import 'package:busta/features/cart/data/models/shipping_rate_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Cart Integration according to FLUTTER_CART_DOCUMENTATION.md', () {
    test('CartDataModel parses backend get cart response correctly', () {
      final json = {
        "status": "success",
        "data": {
          "cartId": "d3b07384-d113-40e4-a14a-f5b24479e09d",
          "cartTotal": 49.98,
          "items": [
            {
              "cartItemId": "c1a93822-7711-4202-b2d9-a42e1284a112",
              "variantId": "8f39b1a0-9c22-421d-b873-123456789abc",
              "quantity": 2,
              "productId": "e2298c40-3b91-49b9-8765-987654321fed",
              "productName": "Handmade Artisan Fettuccine",
              "slug": "handmade-artisan-fettuccine",
              "storeId": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
              "weightInKg": "0.500",
              "attributes": {
                "weight": "500g",
                "type": "Fresh"
              },
              "price": "24.99",
              "compareAtPrice": "29.99",
              "discountEndDate": "2026-12-31T23:59:59.000Z",
              "stockQuantity": 15,
              "sku": "FETT-500G-FRESH",
              "variantImageId": "img-111",
              "activePrice": "24.99",
              "isSaleActive": true,
              "images": [
                {
                  "id": "img-111",
                  "productId": "e2298c40-3b91-49b9-8765-987654321fed",
                  "imageUrl": "https://res.cloudinary.com/pasta/image/upload/v1/fettuccine.jpg",
                  "orderIndex": 0
                }
              ]
            }
          ]
        }
      };

      final cartData = CartDataModel.fromJson(json);

      expect(cartData.cartId, 'd3b07384-d113-40e4-a14a-f5b24479e09d');
      expect(cartData.cartTotal, 49.98);
      expect(cartData.items.length, 1);

      final item = cartData.items.first;
      expect(item.cartItemId, 'c1a93822-7711-4202-b2d9-a42e1284a112');
      expect(item.variantId, '8f39b1a0-9c22-421d-b873-123456789abc');
      expect(item.effectiveVariantId, '8f39b1a0-9c22-421d-b873-123456789abc');
      expect(item.productId, 'e2298c40-3b91-49b9-8765-987654321fed');
      expect(item.name, 'Handmade Artisan Fettuccine');
      expect(item.slug, 'handmade-artisan-fettuccine');
      expect(item.storeId, 'a1b2c3d4-e5f6-7890-abcd-ef1234567890');
      expect(item.weightInKg, '0.500');
      expect(item.attributes?['weight'], '500g');
      expect(item.attributes?['type'], 'Fresh');
      expect(item.price, 24.99);
      expect(item.compareAtPrice, 29.99);
      expect(item.discountEndDate, '2026-12-31T23:59:59.000Z');
      expect(item.stockQuantity, 15);
      expect(item.sku, 'FETT-500G-FRESH');
      expect(item.variantImageId, 'img-111');
      expect(item.activePrice, 24.99);
      expect(item.isSaleActive, isTrue);
      expect(item.imageUrl, 'https://res.cloudinary.com/pasta/image/upload/v1/fettuccine.jpg');
      expect(item.totalPrice, 49.98);
    });

    test('CartCouponModel parses coupon application result correctly', () {
      final json = {
        "status": "success",
        "data": {
          "cartTotal": 50.00,
          "discountAmount": 10.00,
          "finalTotal": 40.00,
          "appliedCoupon": "PASTA20",
          "message": "Coupon applied successfully!"
        }
      };

      final coupon = CartCouponModel.fromJson(json);

      expect(coupon.cartTotal, 50.0);
      expect(coupon.discountAmount, 10.0);
      expect(coupon.finalTotal, 40.0);
      expect(coupon.appliedCoupon, 'PASTA20');
      expect(coupon.message, 'Coupon applied successfully!');
    });

    test('Empty cart response parses without error', () {
      final json = {
        "status": "success",
        "data": {
          "items": [],
          "cartTotal": 0
        }
      };

      final cartData = CartDataModel.fromJson(json);
      expect(cartData.cartTotal, 0.0);
      expect(cartData.items, isEmpty);
      expect(cartData.totalItemCount, 0);
    });

    test('ShippingRateModel parses /api/shipping/calculate response correctly', () {
      final json = {
        "status": "success",
        "data": {
          "city": "Amman",
          "shippingFee": 3.50,
          "estimatedDeliveryDays": "1-2 days"
        }
      };

      final rate = ShippingRateModel.fromJson(json);
      expect(rate.city, 'Amman');
      expect(rate.shippingFee, 3.50);
      expect(rate.estimatedDeliveryDays, '1-2 days');
    });
  });
}
