# 🛒 Flutter Cart Operations Integration Guide
**Pasta e-Commerce API Documentation for Mobile App Developers**

This document provides a comprehensive guide for integrating all Cart operations into the Flutter mobile application for the **Pasta e-Commerce** platform. It details backend API endpoints, payload contracts, Dart data models (`fromJson`/`toJson`), a complete HTTP service implementation using `dio` / `http`, state management examples (Riverpod / Provider), and error handling best practices.

---

## 📋 Table of Contents
1. [General API Specs & Authentication](#1-general-api-specs--authentication)
2. [API Endpoints Overview](#2-api-endpoints-overview)
3. [Endpoint Details & Payloads](#3-endpoint-details--payloads)
   - [Get User Cart](#31-get-user-cart)
   - [Add Item to Cart](#32-add-item-to-cart)
   - [Update Item Quantity](#33-update-item-quantity)
   - [Remove Item from Cart](#34-remove-item-from-cart)
   - [Apply Coupon Code](#35-apply-coupon-code)
4. [Dart Data Models](#4-dart-data-models)
5. [Flutter API Service Implementation](#5-flutter-api-service-implementation)
6. [State Management Example (Riverpod)](#6-state-management-example-riverpod)
7. [Error & Edge Case Handling](#7-error--edge-case-handling)

---

## 1. General API Specs & Authentication

- **Base URL**: `https://<YOUR_API_DOMAIN>/api/carts` (or `http://localhost:5000/api/carts` during development)
- **Headers Required for All Requests**:
  ```http
  Content-Type: application/json
  Authorization: Bearer <USER_JWT_TOKEN>
  ```
> ⚠️ **Authentication Notice**: All cart endpoints require a valid customer JWT token in the `Authorization` header. If unauthenticated, the server returns `401 Unauthorized`.

---

## 2. API Endpoints Overview

| Method | Endpoint | Description | Auth Required |
| :--- | :--- | :--- | :---: |
| `GET` | `/api/carts` | Retrieve current user's active cart with calculated totals | Yes |
| `POST` | `/api/carts/items` | Add a product variant or product item to cart | Yes |
| `PATCH` | `/api/carts/items/:variantId` | Update the quantity of a specific item in cart | Yes |
| `DELETE` | `/api/carts/items/:variantId` | Remove an item from the cart by `variantId` | Yes |
| `POST` | `/api/carts/apply-coupon` | Validate & apply promo code to cart total | Yes |

---

## 3. Endpoint Details & Payloads

### 3.1 Get User Cart
Retrieves the logged-in customer's shopping cart, complete with product details, active variant pricing, image galleries, and subtotal.

- **HTTP Method**: `GET`
- **Path**: `/api/carts`
- **Success Response (`200 OK`)**:
  ```json
  {
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
  }
  ```
- **Empty Cart Response (`200 OK`)**:
  ```json
  {
    "status": "success",
    "data": {
      "items": [],
      "cartTotal": 0
    }
  }
  ```

---

### 3.2 Add Item to Cart
Adds an item to the cart. If the item already exists in the cart, the quantity is automatically incremented (upsert).

- **HTTP Method**: `POST`
- **Path**: `/api/carts/items`
- **Request Body Rules**: Provide **either** `variantId` OR `productId`. Quantity defaults to `1` if omitted.
  ```json
  {
    "variantId": "8f39b1a0-9c22-421d-b873-123456789abc",
    "quantity": 1
  }
  ```
- **Success Response (`200 OK`)**:
  ```json
  {
    "status": "success",
    "message": "Item added to cart",
    "data": {
      "id": "c1a93822-7711-4202-b2d9-a42e1284a112",
      "cartId": "d3b07384-d113-40e4-a14a-f5b24479e09d",
      "variantId": "8f39b1a0-9c22-421d-b873-123456789abc",
      "quantity": 3
    }
  }
  ```
- **Error Responses (`400 Bad Request`)**:
  - Out of stock: `{"status": "error", "message": "Only 2 items left in stock for this variant"}`
  - Inactive product: `{"status": "error", "message": "This product is currently inactive and cannot be purchased."}`
  - Missing parameters: `{"status": "error", "message": "Either variantId or productId must be provided"}`

---

### 3.3 Update Item Quantity
Updates the absolute quantity of an existing item in the cart using `variantId`.

- **HTTP Method**: `PATCH`
- **Path**: `/api/carts/items/:variantId`
- **Request Body**:
  ```json
  {
    "quantity": 4
  }
  ```
- **Success Response (`200 OK`)**:
  ```json
  {
    "status": "success",
    "message": "Cart updated successfully",
    "data": {
      "id": "c1a93822-7711-4202-b2d9-a42e1284a112",
      "cartId": "d3b07384-d113-40e4-a14a-f5b24479e09d",
      "variantId": "8f39b1a0-9c22-421d-b873-123456789abc",
      "quantity": 4
    }
  }
  ```
- **Error Responses (`400 Bad Request`)**:
  - Quantity exceeds stock: `{"status": "error", "message": "Only 3 items left in stock"}`
  - Item not in cart: `{"status": "error", "message": "Item not found in your cart."}`

---

### 3.4 Remove Item from Cart
Deletes a specific product variant from the customer's cart.

- **HTTP Method**: `DELETE`
- **Path**: `/api/carts/items/:variantId`
- **Success Response (`200 OK`)**:
  ```json
  {
    "status": "success",
    "message": "Item removed from cart"
  }
  ```
- **Error Response (`400 Bad Request`)**:
  - `{"status": "error", "message": "Item not found in your cart."}`

---

### 3.5 Apply Coupon Code
Validates and applies a discount promo code to the customer's cart. Supports percentage/fixed discounts and store-specific or global coupons.

- **HTTP Method**: `POST`
- **Path**: `/api/carts/apply-coupon`
- **Request Body**:
  ```json
  {
    "code": "PASTA20"
  }
  ```
- **Success Response (`200 OK`)**:
  ```json
  {
    "status": "success",
    "data": {
      "cartTotal": 50.00,
      "discountAmount": 10.00,
      "finalTotal": 40.00,
      "appliedCoupon": "PASTA20",
      "message": "Coupon applied successfully!"
    }
  }
  ```
- **Error Responses (`400 Bad Request`)**:
  - `Invalid coupon code`
  - `This coupon has expired` / `This coupon is not active yet`
  - `This coupon has reached its maximum usage limit`
  - `This coupon does not apply to any products in your cart.` (for store-specific coupons)
  - `You must spend at least 30.00 JOD on eligible items to use this coupon.`

---

## 4. Dart Data Models

Copy & paste these type-safe models into your Flutter project (`lib/models/cart_models.dart`).

```dart
import 'dart:convert';

class CartResponse {
  final String status;
  final CartData data;

  CartResponse({required this.status, required this.data});

  factory CartResponse.fromJson(Map<String, dynamic> json) {
    return CartResponse(
      status: json['status'] ?? '',
      data: CartData.fromJson(json['data'] ?? {}),
    );
  }
}

class CartData {
  final String? cartId;
  final double cartTotal;
  final List<CartItem> items;

  CartData({
    this.cartId,
    required this.cartTotal,
    required this.items,
  });

  factory CartData.fromJson(Map<String, dynamic> json) {
    return CartData(
      cartId: json['cartId'],
      cartTotal: (json['cartTotal'] as num?)?.toDouble() ?? 0.0,
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => CartItem.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class CartItem {
  final String cartItemId;
  final String variantId;
  final int quantity;
  final String productId;
  final String productName;
  final String slug;
  final String? storeId;
  final String? weightInKg;
  final Map<String, dynamic>? attributes;
  final String price;
  final String? compareAtPrice;
  final String? discountEndDate;
  final int stockQuantity;
  final String? sku;
  final String? variantImageId;
  final String activePrice;
  final bool isSaleActive;
  final List<ProductImage> images;

  CartItem({
    required this.cartItemId,
    required this.variantId,
    required this.quantity,
    required this.productId,
    required this.productName,
    required this.slug,
    this.storeId,
    this.weightInKg,
    this.attributes,
    required this.price,
    this.compareAtPrice,
    this.discountEndDate,
    required this.stockQuantity,
    this.sku,
    this.variantImageId,
    required this.activePrice,
    required this.isSaleActive,
    required this.images,
  });

  double get unitPrice => double.tryParse(activePrice) ?? 0.0;
  double get totalPrice => unitPrice * quantity;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      cartItemId: json['cartItemId'] ?? '',
      variantId: json['variantId'] ?? '',
      quantity: json['quantity'] ?? 1,
      productId: json['productId'] ?? '',
      productName: json['productName'] ?? '',
      slug: json['slug'] ?? '',
      storeId: json['storeId'],
      weightInKg: json['weightInKg'],
      attributes: json['attributes'] != null
          ? Map<String, dynamic>.from(json['attributes'])
          : null,
      price: json['price']?.toString() ?? '0.00',
      compareAtPrice: json['compareAtPrice']?.toString(),
      discountEndDate: json['discountEndDate']?.toString(),
      stockQuantity: json['stockQuantity'] ?? 0,
      sku: json['sku'],
      variantImageId: json['variantImageId'],
      activePrice: json['activePrice']?.toString() ?? json['price']?.toString() ?? '0.00',
      isSaleActive: json['isSaleActive'] ?? false,
      images: (json['images'] as List<dynamic>?)
              ?.map((img) => ProductImage.fromJson(img))
              .toList() ??
          [],
    );
  }
}

class ProductImage {
  final String id;
  final String productId;
  final String imageUrl;
  final int orderIndex;

  ProductImage({
    required this.id,
    required this.productId,
    required this.imageUrl,
    required this.orderIndex,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      id: json['id'] ?? '',
      productId: json['productId'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      orderIndex: json['orderIndex'] ?? 0,
    );
  }
}

class AppliedCouponResult {
  final double cartTotal;
  final double discountAmount;
  final double finalTotal;
  final String appliedCoupon;
  final String message;

  AppliedCouponResult({
    required this.cartTotal,
    required this.discountAmount,
    required this.finalTotal,
    required this.appliedCoupon,
    required this.message,
  });

  factory AppliedCouponResult.fromJson(Map<String, dynamic> json) {
    return AppliedCouponResult(
      cartTotal: (json['cartTotal'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0.0,
      finalTotal: (json['finalTotal'] as num?)?.toDouble() ?? 0.0,
      appliedCoupon: json['appliedCoupon'] ?? '',
      message: json['message'] ?? '',
    );
  }
}
```

---

## 5. Flutter API Service Implementation

Create a robust API client (`lib/services/cart_api_service.dart`) using `dio` (or standard `http`):

```dart
import 'package:dio/dio.dart';
import '../models/cart_models.dart';

class CartApiService {
  final Dio _dio;

  CartApiService(this._dio);

  /// Fetch user's cart
  Future<CartData> getCart() async {
    try {
      final response = await _dio.get('/api/carts');
      return CartData.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Add item to cart
  Future<dynamic> addToCart({
    String? variantId,
    String? productId,
    int quantity = 1,
  }) async {
    try {
      final response = await _dio.post(
        '/api/carts/items',
        data: {
          if (variantId != null) 'variantId': variantId,
          if (productId != null) 'productId': productId,
          'quantity': quantity,
        },
      );
      return response.data['data'];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Update item quantity
  Future<dynamic> updateQuantity({
    required String variantId,
    required int quantity,
  }) async {
    try {
      final response = await _dio.patch(
        '/api/carts/items/$variantId',
        data: {'quantity': quantity},
      );
      return response.data['data'];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Remove item from cart
  Future<void> removeFromCart(String variantId) async {
    try {
      await _dio.delete('/api/carts/items/$variantId');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Apply promo code
  Future<AppliedCouponResult> applyCoupon(String code) async {
    try {
      final response = await _dio.post(
        '/api/carts/apply-coupon',
        data: {'code': code},
      );
      return AppliedCouponResult.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException error) {
    if (error.response?.data != null && error.response?.data['message'] != null) {
      return error.response!.data['message'];
    }
    return 'An unexpected network error occurred. Please try again.';
  }
}
```

---

## 6. State Management Example (Riverpod)

A complete state notifier implementation handling cart state, total recalculation, and coupon state:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cart_models.dart';
import '../services/cart_api_service.dart';

class CartState {
  final bool isLoading;
  final CartData? cartData;
  final AppliedCouponResult? appliedCoupon;
  final String? errorMessage;

  CartState({
    this.isLoading = false,
    this.cartData,
    this.appliedCoupon,
    this.errorMessage,
  });

  CartState copyWith({
    bool? isLoading,
    CartData? cartData,
    AppliedCouponResult? appliedCoupon,
    String? errorMessage,
  }) {
    return CartState(
      isLoading: isLoading ?? this.isLoading,
      cartData: cartData ?? this.cartData,
      appliedCoupon: appliedCoupon ?? this.appliedCoupon,
      errorMessage: errorMessage,
    );
  }
}

class CartNotifier extends StateNotifier<CartState> {
  final CartApiService _apiService;

  CartNotifier(this._apiService) : super(CartState());

  /// Load cart on initial app launch or screen view
  Future<void> fetchCart() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final cart = await _apiService.getCart();
      state = state.copyWith(isLoading: false, cartData: cart);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Add item to cart
  Future<bool> addItem({String? variantId, String? productId, int quantity = 1}) async {
    try {
      await _apiService.addToCart(variantId: variantId, productId: productId, quantity: quantity);
      await fetchCart(); // Refresh cart state
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  /// Increment / Decrement quantity
  Future<void> updateQuantity(String variantId, int newQuantity) async {
    if (newQuantity < 1) {
      await removeItem(variantId);
      return;
    }

    try {
      await _apiService.updateQuantity(variantId: variantId, quantity: newQuantity);
      await fetchCart();
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  /// Remove item
  Future<void> removeItem(String variantId) async {
    try {
      await _apiService.removeFromCart(variantId);
      await fetchCart();
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  /// Apply Coupon
  Future<bool> applyCoupon(String code) async {
    try {
      final result = await _apiService.applyCoupon(code);
      state = state.copyWith(appliedCoupon: result);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }
}
```

---

## 7. Error & Edge Case Handling

1. **Stock Limits**:
   - The backend validates stock on both `POST /api/carts/items` and `PATCH /api/carts/items/:variantId`.
   - If user requests more than `stockQuantity`, the server returns a `400` status with `Only X items left in stock`. Show this message directly in a SnackBar or Toast.

2. **Inactive Products**:
   - Products marked `isActive: false` cannot be added to cart. Handle error `This product is currently inactive and cannot be purchased.`

3. **Store-Specific Coupons**:
   - If a coupon belongs to a specific vendor/store (`storeId != null`), it calculates discount **only** on items matching that `storeId`.
   - If no items in the cart match the coupon's store, backend throws `This coupon does not apply to any products in your cart.`

4. **Cart Count Badge**:
   - Calculate total item count in UI: `cartData.items.fold(0, (sum, item) => sum + item.quantity)` to display on the app bar cart icon.
