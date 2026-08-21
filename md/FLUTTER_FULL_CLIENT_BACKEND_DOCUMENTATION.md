# 📱 Pasta e-Commerce — Complete Customer Flutter App Backend Integration Guide

> 🚀 **Master Integration Spec**: This document provides a complete, 100% exhaustive API reference and integration blueprint for the **Customer Flutter Mobile App**. It covers every single customer-facing backend feature in the **Pasta e-Commerce** platform. Admin and Vendor features (store administration, inventory management, package subscriptions, bulk uploads) are omitted.

---

## 📋 Table of Contents
1. [Architecture & Auth Setup](#1-architecture--auth-setup)
2. [Master Client API Endpoints Overview](#2-master-client-api-endpoints-overview)
3. [Module 1: Authentication & Account Profile](#module-1-authentication--account-profile)
4. [Module 2: Home Promotional Banners](#module-2-home-promotional-banners)
5. [Module 3: Marketplace Stores & Vendors](#module-3-marketplace-stores--vendors)
6. [Module 4: Categories & Product Catalog](#module-4-categories--product-catalog)
7. [Module 5: Cart & Promo Coupons](#module-5-cart--promo-coupons)
8. [Module 6: Shipping Rate Calculator](#module-6-shipping-rate-calculator)
9. [Module 7: Checkout & Order Tracking](#module-7-checkout--order-tracking)
10. [Module 8: Online Card Payment Flow (MPGS)](#module-8-online-card-payment-flow-mpgs)
11. [Module 9: Product Reviews & Ratings](#module-9-product-reviews--ratings)
12. [Module 10: Customer Wishlist / Favorites](#module-10-customer-wishlist--favorites)
13. [Module 11: In-App & Push Notifications (FCM)](#module-11-in-app--push-notifications-fcm)
14. [Complete Dart Data Models Suite](#14-complete-dart-data-models-suite)
15. [Master Dio API Client Service](#15-master-dio-api-client-service)
16. [Flutter Customer Flow & Best Practices](#16-flutter-customer-flow--best-practices)

---

## 1. Architecture & Auth Setup

- **Base URL**: `https://<YOUR_API_DOMAIN>/api` (Development: `http://localhost:3000/api`)
- **Headers Configuration**:
  ```http
  Content-Type: application/json
  Authorization: Bearer <JWT_ACCESS_TOKEN>
  ```
- **Authentication Flow**:
  - Unauthenticated endpoints: Login, Register, Forgot Password, Browse Products, Get Categories, Get Stores, Get Banners, Get Reviews.
  - Protected endpoints require `Authorization: Bearer <TOKEN>`. Returns `401 Unauthorized` if token is missing or expired.

---

## 2. Master Client API Endpoints Overview

| Module | Method | Endpoint | Auth | Description |
| :--- | :--- | :--- | :---: | :--- |
| **Auth** | `POST` | `/api/users/register` | No | Register new customer account |
| **Auth** | `POST` | `/api/users/login` | No | Customer login (email/password) |
| **Auth** | `POST` | `/api/users/social-login` | No | Firebase Google/Apple social login |
| **Auth** | `GET` | `/api/users/me` | Yes | Get customer profile data |
| **Auth** | `PATCH` | `/api/users/profile` | Yes | Update profile name, phone, address |
| **Auth** | `POST` | `/api/users/forgot-password` | No | Request password reset code |
| **Auth** | `POST` | `/api/users/reset-password` | No | Reset password with token |
| **Auth** | `POST` | `/api/users/change-password` | Yes | Change password when logged in |
| **Auth** | `PATCH` | `/api/users/fcm-token` | Yes | Register Firebase FCM push token |
| **Banners**| `GET` | `/api/banners` | No | Fetch active home slider banners |
| **Stores** | `GET` | `/api/stores` | No | Browse active stores & vendors |
| **Stores** | `GET` | `/api/stores/:slug` | No | Get store profile & its products |
| **Catalog**| `GET` | `/api/categories` | No | Fetch all product categories |
| **Catalog**| `GET` | `/api/products` | No | Browse/search/filter products |
| **Catalog**| `GET` | `/api/products/:slug` | No | Get single product detail by slug |
| **Cart** | `GET` | `/api/carts` | Yes | Fetch active customer cart |
| **Cart** | `POST` | `/api/carts/items` | Yes | Add item/variant to cart |
| **Cart** | `PATCH` | `/api/carts/items/:variantId` | Yes | Update item quantity in cart |
| **Cart** | `DELETE`| `/api/carts/items/:variantId` | Yes | Remove item from cart |
| **Cart** | `POST` | `/api/carts/apply-coupon` | Yes | Apply promo code discount |
| **Shipping**|`POST`| `/api/shipping/calculate` | Yes | Calculate live delivery fee by city |
| **Orders** | `POST` | `/api/orders/checkout` | Yes | Convert cart to order |
| **Orders** | `GET` | `/api/orders/me` | Yes | Get customer order history |
| **Orders** | `GET` | `/api/orders/:id` | Yes | Track single order status |
| **Orders** | `GET` | `/api/orders/:id/invoice` | Yes | Download PDF order invoice |
| **Payments**|`GET` | `/api/payments/verify/:orderId` | Yes | Verify MPGS online card payment |
| **Payments**|`POST`| `/api/payments/cancel/:orderId` | Yes | Cancel failed online card payment |
| **Reviews**| `GET` | `/api/products/:id/reviews` | No | Get product reviews |
| **Reviews**| `POST` | `/api/products/:id/reviews` | Yes | Submit product review (Verified) |
| **Reviews**| `DELETE`| `/api/products/reviews/:reviewId`| Yes | Delete own review |
| **Favorites**|`GET`| `/api/favorites` | Yes | Get saved wishlist products |
| **Favorites**|`POST`| `/api/favorites/toggle` | Yes | Toggle product favorite status |
| **Notifications**|`GET`| `/api/notifications` | Yes | Get customer notifications |
| **Notifications**|`GET`| `/api/notifications/unread-count`| Yes | Get unread notification count |
| **Notifications**|`PATCH`| `/api/notifications/:id/read`| Yes | Mark notification as read |

---

## Module 1: Authentication & Account Profile

### 1.1 Customer Registration
- **`POST /api/users/register`**
- **Body**:
  ```json
  {
    "name": "John Doe",
    "email": "john@example.com",
    "password": "Password123!",
    "role": "CUSTOMER",
    "phoneNumber": "+962791234567"
  }
  ```
- **Response (`201 Created`)**:
  ```json
  {
    "status": "success",
    "message": "User registered successfully. Please check your email to confirm your account.",
    "user": { "id": "uuid", "name": "John Doe", "email": "john@example.com", "role": "CUSTOMER" }
  }
  ```

### 1.2 Customer Login
- **`POST /api/users/login`**
- **Body**:
  ```json
  {
    "email": "john@example.com",
    "password": "Password123!"
  }
  ```
- **Response (`200 OK`)**:
  ```json
  {
    "status": "success",
    "token": "eyJhbGciOiJIUzI1NiIsIn...",
    "user": {
      "id": "uuid-v4",
      "name": "John Doe",
      "email": "john@example.com",
      "role": "CUSTOMER",
      "phoneNumber": "+962791234567",
      "isEmailConfirmed": true
    }
  }
  ```

### 1.3 Firebase Social Login (Google / Apple)
- **`POST /api/users/social-login`**
- **Body**:
  ```json
  {
    "idToken": "FIREBASE_ID_TOKEN_FROM_FLUTTER_SDK",
    "role": "CUSTOMER"
  }
  ```
- **Response (`200 OK`)**: Returns application JWT token and user profile object.

### 1.4 Get Profile & Update Profile
- **`GET /api/users/me`** (Headers: `Authorization: Bearer <TOKEN>`)
- **`PATCH /api/users/profile`**
  ```json
  {
    "name": "Johnathan Doe",
    "phoneNumber": "+962799887766"
  }
  ```

### 1.5 Register FCM Token for Push Notifications
- **`PATCH /api/users/fcm-token`** (Headers: `Authorization: Bearer <TOKEN>`)
- **Body**:
  ```json
  {
    "fcmToken": "eXz19_FCM_DEVICE_TOKEN_STRING..."
  }
  ```

---

## Module 2: Home Promotional Banners

- **`GET /api/banners`**
- **Public**: Fetches active hero banners for home sliders.
- **Response (`200 OK`)**:
  ```json
  {
    "status": "success",
    "data": [
      {
        "id": "banner-001",
        "title": "Fresh Italian Pasta Weekend Sale",
        "imageUrl": "https://res.cloudinary.com/pasta/image/upload/v1/banner1.jpg",
        "targetUrl": "/products/handmade-artisan-fettuccine"
      }
    ]
  }
  ```

---

## Module 3: Marketplace Stores & Vendors

### 3.1 Browse Stores
- **`GET /api/stores?page=1&limit=10&search=pasta`**
- **Response (`200 OK`)**:
  ```json
  {
    "status": "success",
    "totalItems": 12,
    "totalPages": 2,
    "currentPage": 1,
    "data": [
      {
        "id": "store-101",
        "name": "La Pasta Bella",
        "slug": "la-pasta-bella",
        "description": "Authentic Italian fresh pasta store in Amman",
        "logoUrl": "https://res.cloudinary.com/pasta/image/upload/v1/logo.png",
        "bannerUrl": "https://res.cloudinary.com/pasta/image/upload/v1/store-banner.jpg",
        "rating": 4.8
      }
    ]
  }
  ```

### 3.2 Get Single Store Details
- **`GET /api/stores/:slug`**
- Returns store profile and store's specific product list.

---

## Module 4: Categories & Product Catalog

### 4.1 Get Categories
- **`GET /api/categories`**
- Returns all categories (`id`, `name`, `slug`, `imageUrl`).

### 4.2 Browse & Search Products
- **`GET /api/products?page=1&limit=10&search=fettuccine&category=fresh-pasta&store=la-pasta-bella`**
- **Response (`200 OK`)**:
  ```json
  {
    "status": "success",
    "totalItems": 24,
    "totalPages": 3,
    "currentPage": 1,
    "data": [
      {
        "id": "prod-001",
        "name": "Handmade Artisan Fettuccine",
        "slug": "handmade-artisan-fettuccine",
        "basePrice": "24.99",
        "storeName": "La Pasta Bella",
        "categoryName": "Fresh Pasta",
        "price": "24.99",
        "compareAtPrice": "29.99",
        "discountEndDate": "2026-12-31T23:59:59.000Z",
        "stockQuantity": 20,
        "defaultVariantId": "var-001",
        "variants": [
          {
            "id": "var-001",
            "attributes": { "weight": "500g" },
            "price": "24.99",
            "compareAtPrice": "29.99",
            "stockQuantity": 20
          }
        ],
        "images": [
          { "id": "img-01", "imageUrl": "https://example.com/fettuccine.jpg", "orderIndex": 0 }
        ]
      }
    ]
  }
  ```

### 4.3 Get Product by Slug
- **`GET /api/products/:slug`**
- Full details view with all selectable variants and high-res gallery images.

---

## Module 5: Cart & Promo Coupons

### 5.1 Get Active Cart
- **`GET /api/carts`** (Auth Required)
- **Response (`200 OK`)**:
  ```json
  {
    "status": "success",
    "data": {
      "cartId": "cart-uuid",
      "cartTotal": 49.98,
      "items": [
        {
          "cartItemId": "item-uuid",
          "variantId": "var-001",
          "quantity": 2,
          "productId": "prod-001",
          "productName": "Handmade Artisan Fettuccine",
          "price": "24.99",
          "activePrice": "24.99",
          "isSaleActive": true,
          "images": [{ "imageUrl": "https://example.com/image.jpg" }]
        }
      ]
    }
  }
  ```

### 5.2 Add Item to Cart
- **`POST /api/carts/items`**
- **Body**: `{ "variantId": "var-001", "quantity": 1 }` or `{ "productId": "prod-001", "quantity": 1 }`

### 5.3 Update Quantity & Remove Item
- **`PATCH /api/carts/items/:variantId`** Body: `{ "quantity": 3 }`
- **`DELETE /api/carts/items/:variantId`**

### 5.4 Apply Promo Coupon
- **`POST /api/carts/apply-coupon`**
- **Body**: `{ "code": "PASTA20" }`
- **Response**: Returns `cartTotal`, `discountAmount`, `finalTotal`, and `appliedCoupon`.

---

## Module 6: Shipping Rate Calculator

- **`POST /api/shipping/calculate`** (Auth Required)
- **Body**:
  ```json
  {
    "city": "Amman",
    "streetAddress": "7th Circle, Building 12"
  }
  ```
- **Response (`200 OK`)**:
  ```json
  {
    "status": "success",
    "data": {
      "city": "Amman",
      "shippingFee": 3.50,
      "estimatedDeliveryDays": "1-2 days"
    }
  }
  ```

---

## Module 7: Checkout & Order Tracking

### 7.1 Place Order / Checkout
- **`POST /api/orders/checkout`** (Auth Required)
- **Body**:
  ```json
  {
    "streetAddress": "7th Circle, Building 12",
    "city": "Amman",
    "state": "Amman",
    "postalCode": "11183",
    "country": "Jordan",
    "couponCode": "PASTA20",
    "paymentMethod": "CARD" 
  }
  ```
  *(Note: `paymentMethod` can be `"CARD"` or `"COD"`)*
- **Response (`201 Created`)**:
  ```json
  {
    "status": "success",
    "message": "Order created successfully",
    "data": {
      "orderId": "order-uuid-99",
      "orderNumber": "ORD-2026-0042",
      "totalAmount": 53.48,
      "paymentMethod": "CARD",
      "paymentStatus": "PENDING",
      "orderStatus": "PROCESSING",
      "paymentSession": {
        "sessionId": "SESSION000213912903",
        "merchantId": "PASTA_STORE",
        "checkoutUrl": "https://gateway.mastercard.com/checkout/entry..."
      }
    }
  }
  ```

### 7.2 Customer Orders History & Status Tracking
- **`GET /api/orders/me`**: Get all past and active orders for logged-in customer.
- **`GET /api/orders/:id`**: Track status (`PROCESSING`, `SHIPPED`, `DELIVERED`, `CANCELLED`).
- **`GET /api/orders/:id/invoice`**: PDF invoice download link.

---

## Module 8: Online Card Payment Flow (MPGS)

For card payments (`paymentMethod: "CARD"`), backend integrates with **Mastercard Payment Gateway Services (MPGS)**.

1. **Flutter Trigger**: After receiving `paymentSession` from `/api/orders/checkout`, open the MPGS SDK or Webview checkout modal using `paymentSession.sessionId`.
2. **Verify Payment Endpoint**:
   - **`GET /api/payments/verify/:orderId`** (Auth Required)
   - Call after Mastercard modal completes. Backend verifies transaction status with Mastercard servers and updates order `paymentStatus` to `PAID`.
3. **Cancel Payment Endpoint**:
   - **`POST /api/payments/cancel/:orderId`** (Auth Required)
   - Call if customer closes or cancels the card payment modal.

---

## Module 9: Product Reviews & Ratings

- **`GET /api/products/:id/reviews`**: Get reviews list.
- **`POST /api/products/:id/reviews`** (Auth Required):
  - **Body**: `{ "rating": 5, "comment": "Excellent quality!" }`
  - *Rule*: Only customers with verified completed orders for this item can review.
- **`DELETE /api/products/reviews/:reviewId`** (Auth Required): Delete customer's own review.

---

## Module 10: Customer Wishlist / Favorites

- **`GET /api/favorites`** (Auth Required): Fetch user's wishlist.
- **`POST /api/favorites/toggle`** (Auth Required):
  - **Body**: `{ "productId": "prod-001" }`
  - **Response**: `{ "status": "success", "isFavorite": true }`

---

## Module 11: In-App & Push Notifications (FCM)

- **`GET /api/notifications`**: Fetch customer notification feed.
- **`GET /api/notifications/unread-count`**: Unread count badge.
- **`PATCH /api/notifications/:id/read`**: Mark notification read.

---

## 14. Complete Dart Data Models Suite

Save in `lib/models/pasta_models.dart`:

```dart
// User & Auth Models
class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? phoneNumber;
  final bool isEmailConfirmed;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phoneNumber,
    this.isEmailConfirmed = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'CUSTOMER',
      phoneNumber: json['phoneNumber'],
      isEmailConfirmed: json['isEmailConfirmed'] ?? false,
    );
  }
}

class AuthResponse {
  final String status;
  final String? token;
  final User? user;
  final String? message;

  AuthResponse({required this.status, this.token, this.user, this.message});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      status: json['status'] ?? '',
      token: json['token'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      message: json['message'],
    );
  }
}

// Banner Model
class BannerItem {
  final String id;
  final String title;
  final String imageUrl;
  final String? targetUrl;

  BannerItem({required this.id, required this.title, required this.imageUrl, this.targetUrl});

  factory BannerItem.fromJson(Map<String, dynamic> json) {
    return BannerItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      targetUrl: json['targetUrl'],
    );
  }
}

// Store Model
class Store {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final String? logoUrl;
  final String? bannerUrl;

  Store({required this.id, required this.name, required this.slug, this.description, this.logoUrl, this.bannerUrl});

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'],
      logoUrl: json['logoUrl'],
      bannerUrl: json['bannerUrl'],
    );
  }
}

// Product & Catalog Models
class ProductItem {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final String basePrice;
  final String? storeName;
  final String? categoryName;
  final String price;
  final String? compareAtPrice;
  final int stockQuantity;
  final String? defaultVariantId;
  final List<ProductVariant> variants;
  final List<ProductImage> images;

  ProductItem({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    required this.basePrice,
    this.storeName,
    this.categoryName,
    required this.price,
    this.compareAtPrice,
    required this.stockQuantity,
    this.defaultVariantId,
    required this.variants,
    required this.images,
  });

  factory ProductItem.fromJson(Map<String, dynamic> json) {
    return ProductItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'],
      basePrice: json['basePrice']?.toString() ?? '0.00',
      storeName: json['storeName'],
      categoryName: json['categoryName'],
      price: json['price']?.toString() ?? '0.00',
      compareAtPrice: json['compareAtPrice']?.toString(),
      stockQuantity: json['stockQuantity'] ?? 0,
      defaultVariantId: json['defaultVariantId'],
      variants: (json['variants'] as List<dynamic>?)?.map((v) => ProductVariant.fromJson(v)).toList() ?? [],
      images: (json['images'] as List<dynamic>?)?.map((i) => ProductImage.fromJson(i)).toList() ?? [],
    );
  }
}

class ProductVariant {
  final String id;
  final Map<String, dynamic> attributes;
  final String price;
  final String? compareAtPrice;
  final int stockQuantity;

  ProductVariant({required this.id, required this.attributes, required this.price, this.compareAtPrice, required this.stockQuantity});

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['id'] ?? '',
      attributes: json['attributes'] != null ? Map<String, dynamic>.from(json['attributes']) : {},
      price: json['price']?.toString() ?? '0.00',
      compareAtPrice: json['compareAtPrice']?.toString(),
      stockQuantity: json['stockQuantity'] ?? 0,
    );
  }
}

class ProductImage {
  final String id;
  final String imageUrl;
  final int orderIndex;

  ProductImage({required this.id, required this.imageUrl, required this.orderIndex});

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      id: json['id'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      orderIndex: json['orderIndex'] ?? 0,
    );
  }
}

// Order & Checkout Models
class CheckoutResponse {
  final String orderId;
  final String orderNumber;
  final double totalAmount;
  final String paymentMethod;
  final String paymentStatus;
  final String orderStatus;
  final Map<String, dynamic>? paymentSession;

  CheckoutResponse({
    required this.orderId,
    required this.orderNumber,
    required this.totalAmount,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.orderStatus,
    this.paymentSession,
  });

  factory CheckoutResponse.fromJson(Map<String, dynamic> json) {
    return CheckoutResponse(
      orderId: json['orderId'] ?? '',
      orderNumber: json['orderNumber'] ?? '',
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: json['paymentMethod'] ?? 'CARD',
      paymentStatus: json['paymentStatus'] ?? 'PENDING',
      orderStatus: json['orderStatus'] ?? 'PROCESSING',
      paymentSession: json['paymentSession'],
    );
  }
}
```

---

## 15. Master Dio API Client Service

Save in `lib/services/pasta_api_service.dart`:

```dart
import 'package:dio/dio.dart';
import '../models/pasta_models.dart';

class PastaApiService {
  final Dio _dio;

  PastaApiService(this._dio);

  // Auth Methods
  Future<AuthResponse> login(String email, String password) async {
    final res = await _dio.post('/api/users/login', data: {'email': email, 'password': password});
    return AuthResponse.fromJson(res.data);
  }

  Future<AuthResponse> register(String name, String email, String password, String phone) async {
    final res = await _dio.post('/api/users/register', data: {
      'name': name, 'email': email, 'password': password, 'phoneNumber': phone, 'role': 'CUSTOMER'
    });
    return AuthResponse.fromJson(res.data);
  }

  Future<void> updateFcmToken(String fcmToken) async {
    await _dio.patch('/api/users/fcm-token', data: {'fcmToken': fcmToken});
  }

  // Home Banners & Categories
  Future<List<BannerItem>> getBanners() async {
    final res = await _dio.get('/api/banners');
    return (res.data['data'] as List).map((b) => BannerItem.fromJson(b)).toList();
  }

  // Catalog & Search
  Future<List<ProductItem>> searchProducts({String? query, String? categorySlug}) async {
    final res = await _dio.get('/api/products', queryParameters: {
      if (query != null) 'search': query,
      if (categorySlug != null) 'category': categorySlug,
    });
    return (res.data['data'] as List).map((p) => ProductItem.fromJson(p)).toList();
  }

  // Checkout
  Future<CheckoutResponse> checkout({
    required String streetAddress,
    required String city,
    required String state,
    required String postalCode,
    required String country,
    String? couponCode,
    String paymentMethod = 'CARD',
  }) async {
    final res = await _dio.post('/api/orders/checkout', data: {
      'streetAddress': streetAddress,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
      if (couponCode != null) 'couponCode': couponCode,
      'paymentMethod': paymentMethod,
    });
    return CheckoutResponse.fromJson(res.data['data']);
  }
}
```

---

## 16. Flutter Customer Flow & Best Practices

1. **Token Persistence**: Store the JWT token securely using `flutter_secure_storage` and attach it to Dio interceptors:
   ```dart
   dio.interceptors.add(InterceptorsWrapper(
     onRequest: (options, handler) async {
       final token = await secureStorage.read(key: 'jwt_token');
       if (token != null) {
         options.headers['Authorization'] = 'Bearer $token';
       }
       return handler.next(options);
     },
   ));
   ```
2. **Push Notifications**: Register FCM token right after login using `_apiService.updateFcmToken(fcmToken)`.
3. **Cart & Favorites Sync**: Fetch `/api/carts` and `/api/favorites` immediately after user logs in.
