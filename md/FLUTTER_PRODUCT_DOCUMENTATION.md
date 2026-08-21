# 🛍️ Flutter Product & Catalog Operations Integration Guide
**Pasta e-Commerce Customer App API Documentation**

> 📱 **Customer App Scope**: This document is specifically tailored for the **Customer Flutter Mobile App**. It covers product browsing, searching, filtering, detail views, variant selection, categories, verified customer reviews, and wishlist (favorites). Vendor and Admin product management endpoints (create, edit, delete, bulk upload) are excluded.

---

## 📋 Table of Contents
1. [General Specs & Authentication](#1-general-specs--authentication)
2. [Customer Product API Endpoints Summary](#2-customer-product-api-endpoints-summary)
3. [Endpoint Details & Payloads](#3-endpoint-details--payloads)
   - [Browse & Search Products](#31-browse--search-products)
   - [Get Product Details by Slug](#32-get-product-details-by-slug)
   - [Get All Categories](#33-get-all-categories)
   - [Fetch Product Reviews](#34-fetch-product-reviews)
   - [Submit Product Review (Verified Buyer)](#35-submit-product-review-verified-buyer)
   - [Delete Own Review](#36-delete-own-review)
   - [Get Customer Wishlist / Favorites](#37-get-customer-wishlist--favorites)
   - [Toggle Product Favorite](#38-toggle-product-favorite)
4. [Dart Data Models](#4-dart-data-models)
5. [Flutter API Service Implementation](#5-flutter-api-service-implementation)
6. [State Management Example (Riverpod)](#6-state-management-example-riverpod)
7. [Product & Variant Business Logic Rules](#7-product--variant-business-logic-rules)

---

## 1. General Specs & Authentication

- **Base URL**: `https://<YOUR_API_DOMAIN>/api` (or `http://localhost:3000/api` during development)
- **Headers**:
  ```http
  Content-Type: application/json
  Authorization: Bearer <CUSTOMER_JWT_TOKEN> (Optional for browsing, Required for Reviews & Favorites)
  ```

---

## 2. Customer Product API Endpoints Summary

| Method | Endpoint | Auth Required | Description |
| :--- | :--- | :---: | :--- |
| `GET` | `/api/products` | Optional | Browse products with search, category/store filters, and pagination |
| `GET` | `/api/products/:slug` | Optional | Get full product details by URL slug including all variants & gallery images |
| `GET` | `/api/categories` | Optional | Get all product categories for UI filter chips / category grids |
| `GET` | `/api/products/:id/reviews` | Optional | Get customer reviews and ratings for a product |
| `POST` | `/api/products/:id/reviews` | Yes | Submit a rating & review (Requires verified purchase) |
| `DELETE` | `/api/products/reviews/:reviewId` | Yes | Delete customer's own review |
| `GET` | `/api/favorites` | Yes | Get current user's saved wishlist products |
| `POST` | `/api/favorites/toggle` | Yes | Toggle product favorite / unfavorite status |

---

## 3. Endpoint Details & Payloads

### 3.1 Browse & Search Products
Retrieves active products with optional search query, category filter, store filter, and pagination.

- **HTTP Method**: `GET`
- **Path**: `/api/products`
- **Query Parameters**:
  - `page` (number, default: `1`): Current page number.
  - `limit` (number, default: `10`, max: `100`): Items per page.
  - `search` (string, optional): Keyword search in product name.
  - `category` (string, optional): Filter by category `slug` (e.g., `fresh-pasta`).
  - `store` (string, optional): Filter by store `slug` (e.g., `pasta-house`).
- **Success Response (`200 OK`)**:
  ```json
  {
    "status": "success",
    "totalItems": 45,
    "totalPages": 5,
    "currentPage": 1,
    "limit": 10,
    "data": [
      {
        "id": "e2298c40-3b91-49b9-8765-987654321fed",
        "name": "Handmade Artisan Fettuccine",
        "slug": "handmade-artisan-fettuccine",
        "basePrice": "24.99",
        "storeName": "La Pasta Bella",
        "storeSlug": "la-pasta-bella",
        "categoryName": "Fresh Pasta",
        "categorySlug": "fresh-pasta",
        "price": "24.99",
        "compareAtPrice": "29.99",
        "discountEndDate": "2026-12-31T23:59:59.000Z",
        "stockQuantity": 25,
        "defaultVariantId": "8f39b1a0-9c22-421d-b873-123456789abc",
        "variants": [
          {
            "id": "8f39b1a0-9c22-421d-b873-123456789abc",
            "productId": "e2298c40-3b91-49b9-8765-987654321fed",
            "attributes": { "weight": "500g", "sauce": "Bolognese" },
            "price": "24.99",
            "compareAtPrice": "29.99",
            "discountEndDate": "2026-12-31T23:59:59.000Z",
            "stockQuantity": 15,
            "sku": "FETT-500G",
            "imageId": "img-001"
          }
        ],
        "images": [
          {
            "id": "img-001",
            "productId": "e2298c40-3b91-49b9-8765-987654321fed",
            "imageUrl": "https://res.cloudinary.com/pasta/image/upload/v1/fettuccine.jpg",
            "orderIndex": 0
          }
        ]
      }
    ]
  }
  ```

---

### 3.2 Get Product Details by Slug
Fetches a single product page's data using its unique URL `slug`.

- **HTTP Method**: `GET`
- **Path**: `/api/products/:slug`
- **Success Response (`200 OK`)**:
  ```json
  {
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
          "attributes": { "size": "500g" },
          "price": "24.99",
          "compareAtPrice": "29.99",
          "discountEndDate": "2026-12-31T23:59:59.000Z",
          "stockQuantity": 15,
          "sku": "FETT-500G"
        },
        {
          "id": "9a40c2b1-0d33-532e-c984-234567890def",
          "productId": "e2298c40-3b91-49b9-8765-987654321fed",
          "attributes": { "size": "1kg" },
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
  }
  ```
- **Error Response (`404 Not Found`)**:
  - `{"status": "error", "message": "Product not found"}`

---

### 3.3 Get All Categories
Retrieves all active product categories for building category chips or grid menus.

- **HTTP Method**: `GET`
- **Path**: `/api/categories`
- **Success Response (`200 OK`)**:
  ```json
  {
    "status": "success",
    "data": [
      {
        "id": "cat-001",
        "name": "Fresh Pasta",
        "slug": "fresh-pasta",
        "description": "Handmade fresh pasta egg noodles",
        "imageUrl": "https://res.cloudinary.com/pasta/image/upload/v1/fresh-pasta-cat.jpg"
      },
      {
        "id": "cat-002",
        "name": "Sauces & Pesto",
        "slug": "sauces-pesto",
        "description": "Traditional Italian pasta sauces",
        "imageUrl": "https://res.cloudinary.com/pasta/image/upload/v1/sauces-cat.jpg"
      }
    ]
  }
  ```

---

### 3.4 Fetch Product Reviews
Fetches user reviews for a specific product.

- **HTTP Method**: `GET`
- **Path**: `/api/products/:id/reviews`
- **Success Response (`200 OK`)**:
  ```json
  {
    "status": "success",
    "data": [
      {
        "id": "rev-101",
        "rating": 5,
        "comment": "The freshest pasta I have ordered in Amman! Will buy again.",
        "createdAt": "2026-08-10T14:20:00.000Z",
        "customerName": "Ahmad M."
      }
    ]
  }
  ```

---

### 3.5 Submit Product Review (Verified Buyer)
Submits a star rating (1–5) and review comment for a product.

- **HTTP Method**: `POST`
- **Path**: `/api/products/:id/reviews`
- **Auth Required**: Yes (`Bearer <TOKEN>`)
- **Request Body**:
  ```json
  {
    "rating": 5,
    "comment": "Delicious texture and fast delivery!"
  }
  ```
- **Success Response (`201 Created`)**:
  ```json
  {
    "status": "success",
    "message": "Review added successfully",
    "data": {
      "id": "rev-102",
      "productId": "e2298c40-3b91-49b9-8765-987654321fed",
      "userId": "user-777",
      "rating": 5,
      "comment": "Delicious texture and fast delivery!",
      "createdAt": "2026-08-15T10:00:00.000Z"
    }
  }
  ```
- **Error Response (`400 Bad Request`)**:
  - Unverified purchase: `{"status": "error", "message": "Verified Purchase Required: You can only review products you have bought and successfully received."}`

---

### 3.6 Delete Own Review
Deletes a review submitted by the customer.

- **HTTP Method**: `DELETE`
- **Path**: `/api/products/reviews/:reviewId`
- **Auth Required**: Yes (`Bearer <TOKEN>`)
- **Success Response (`200 OK`)**:
  ```json
  {
    "status": "success",
    "message": "Review deleted successfully"
  }
  ```

---

### 3.7 Get Customer Wishlist / Favorites
Retrieves all products saved to the logged-in customer's favorites list.

- **HTTP Method**: `GET`
- **Path**: `/api/favorites`
- **Auth Required**: Yes (`Bearer <TOKEN>`)
- **Success Response (`200 OK`)**:
  ```json
  {
    "status": "success",
    "data": [
      {
        "favoriteId": "fav-99",
        "productId": "e2298c40-3b91-49b9-8765-987654321fed",
        "productName": "Handmade Artisan Fettuccine",
        "slug": "handmade-artisan-fettuccine",
        "price": "24.99",
        "imageUrl": "https://res.cloudinary.com/pasta/image/upload/v1/fettuccine.jpg",
        "storeName": "La Pasta Bella"
      }
    ]
  }
  ```

---

### 3.8 Toggle Product Favorite
Toggles a product in or out of the customer's wishlist.

- **HTTP Method**: `POST`
- **Path**: `/api/favorites/toggle`
- **Auth Required**: Yes (`Bearer <TOKEN>`)
- **Request Body**:
  ```json
  {
    "productId": "e2298c40-3b91-49b9-8765-987654321fed"
  }
  ```
- **Success Response (`200 OK`)**:
  ```json
  {
    "status": "success",
    "message": "Product added to favorites",
    "isFavorite": true
  }
  ```

---

## 4. Dart Data Models

Copy & paste these Dart models into `lib/models/product_models.dart`:

```dart
class ProductListResponse {
  final String status;
  final int totalItems;
  final int totalPages;
  final int currentPage;
  final int limit;
  final List<ProductItem> data;

  ProductListResponse({
    required this.status,
    required this.totalItems,
    required this.totalPages,
    required this.currentPage,
    required this.limit,
    required this.data,
  });

  factory ProductListResponse.fromJson(Map<String, dynamic> json) {
    return ProductListResponse(
      status: json['status'] ?? '',
      totalItems: json['totalItems'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      currentPage: json['currentPage'] ?? 1,
      limit: json['limit'] ?? 10,
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => ProductItem.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class ProductItem {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final String basePrice;
  final String? weightInKg;
  final String? storeName;
  final String? storeSlug;
  final String? categoryName;
  final String? categorySlug;
  final String price;
  final String? compareAtPrice;
  final String? discountEndDate;
  final int stockQuantity;
  final String? sku;
  final String? defaultVariantId;
  final List<ProductVariant> variants;
  final List<ProductImage> images;

  ProductItem({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    required this.basePrice,
    this.weightInKg,
    this.storeName,
    this.storeSlug,
    this.categoryName,
    this.categorySlug,
    required this.price,
    this.compareAtPrice,
    this.discountEndDate,
    required this.stockQuantity,
    this.sku,
    this.defaultVariantId,
    required this.variants,
    required this.images,
  });

  double get displayPrice => double.tryParse(price) ?? 0.0;
  double? get originalPrice =>
      compareAtPrice != null ? double.tryParse(compareAtPrice!) : null;

  bool get isOnSale {
    if (compareAtPrice == null) return false;
    if (discountEndDate == null) return true;
    final endDate = DateTime.tryParse(discountEndDate!);
    return endDate != null && endDate.isAfter(DateTime.now());
  }

  String get defaultImageUrl =>
      images.isNotEmpty ? images.first.imageUrl : '';

  factory ProductItem.fromJson(Map<String, dynamic> json) {
    return ProductItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'],
      basePrice: json['basePrice']?.toString() ?? '0.00',
      weightInKg: json['weightInKg']?.toString(),
      storeName: json['storeName'],
      storeSlug: json['storeSlug'],
      categoryName: json['categoryName'],
      categorySlug: json['categorySlug'],
      price: json['price']?.toString() ?? json['basePrice']?.toString() ?? '0.00',
      compareAtPrice: json['compareAtPrice']?.toString(),
      discountEndDate: json['discountEndDate']?.toString(),
      stockQuantity: json['stockQuantity'] ?? 0,
      sku: json['sku'],
      defaultVariantId: json['defaultVariantId'],
      variants: (json['variants'] as List<dynamic>?)
              ?.map((v) => ProductVariant.fromJson(v))
              .toList() ??
          [],
      images: (json['images'] as List<dynamic>?)
              ?.map((i) => ProductImage.fromJson(i))
              .toList() ??
          [],
    );
  }
}

class ProductVariant {
  final String id;
  final String? productId;
  final Map<String, dynamic> attributes;
  final String price;
  final String? compareAtPrice;
  final String? discountEndDate;
  final int stockQuantity;
  final String? sku;
  final String? imageId;

  ProductVariant({
    required this.id,
    this.productId,
    required this.attributes,
    required this.price,
    this.compareAtPrice,
    this.discountEndDate,
    required this.stockQuantity,
    this.sku,
    this.imageId,
  });

  double get variantPrice => double.tryParse(price) ?? 0.0;

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['id'] ?? '',
      productId: json['productId'],
      attributes: json['attributes'] != null
          ? Map<String, dynamic>.from(json['attributes'])
          : {},
      price: json['price']?.toString() ?? '0.00',
      compareAtPrice: json['compareAtPrice']?.toString(),
      discountEndDate: json['discountEndDate']?.toString(),
      stockQuantity: json['stockQuantity'] ?? 0,
      sku: json['sku'],
      imageId: json['imageId'],
    );
  }
}

class ProductImage {
  final String id;
  final String? productId;
  final String imageUrl;
  final int orderIndex;

  ProductImage({
    required this.id,
    this.productId,
    required this.imageUrl,
    required this.orderIndex,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      id: json['id'] ?? '',
      productId: json['productId'],
      imageUrl: json['imageUrl'] ?? '',
      orderIndex: json['orderIndex'] ?? 0,
    );
  }
}

class Category {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final String? imageUrl;

  Category({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.imageUrl,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'],
      imageUrl: json['imageUrl'],
    );
  }
}

class ProductReview {
  final String id;
  final int rating;
  final String? comment;
  final String createdAt;
  final String customerName;

  ProductReview({
    required this.id,
    required this.rating,
    this.comment,
    required this.createdAt,
    required this.customerName,
  });

  factory ProductReview.fromJson(Map<String, dynamic> json) {
    return ProductReview(
      id: json['id'] ?? '',
      rating: json['rating'] ?? 5,
      comment: json['comment'],
      createdAt: json['createdAt'] ?? '',
      customerName: json['customerName'] ?? 'Anonymous Customer',
    );
  }
}
```

---

## 5. Flutter API Service Implementation

Create `lib/services/product_api_service.dart`:

```dart
import 'package:dio/dio.dart';
import '../models/product_models.dart';

class ProductApiService {
  final Dio _dio;

  ProductApiService(this._dio);

  /// Browse & Search Products
  Future<ProductListResponse> getProducts({
    int page = 1,
    int limit = 10,
    String? search,
    String? categorySlug,
    String? storeSlug,
  }) async {
    try {
      final response = await _dio.get('/api/products', queryParameters: {
        'page': page,
        'limit': limit,
        if (search != null && search.isNotEmpty) 'search': search,
        if (categorySlug != null && categorySlug.isNotEmpty) 'category': categorySlug,
        if (storeSlug != null && storeSlug.isNotEmpty) 'store': storeSlug,
      });
      return ProductListResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get Product Details by Slug
  Future<ProductItem> getProductBySlug(String slug) async {
    try {
      final response = await _dio.get('/api/products/$slug');
      return ProductItem.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get All Categories
  Future<List<Category>> getCategories() async {
    try {
      final response = await _dio.get('/api/categories');
      return (response.data['data'] as List<dynamic>)
          .map((c) => Category.fromJson(c))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Fetch Reviews
  Future<List<ProductReview>> getReviews(String productId) async {
    try {
      final response = await _dio.get('/api/products/$productId/reviews');
      return (response.data['data'] as List<dynamic>)
          .map((r) => ProductReview.fromJson(r))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Submit Verified Review
  Future<void> submitReview({
    required String productId,
    required int rating,
    String? comment,
  }) async {
    try {
      await _dio.post('/api/products/$productId/reviews', data: {
        'rating': rating,
        if (comment != null) 'comment': comment,
      });
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Toggle Favorite
  Future<bool> toggleFavorite(String productId) async {
    try {
      final response = await _dio.post('/api/favorites/toggle', data: {
        'productId': productId,
      });
      return response.data['isFavorite'] ?? false;
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

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product_models.dart';
import '../services/product_api_service.dart';

class ProductListState {
  final bool isLoading;
  final List<ProductItem> products;
  final int currentPage;
  final bool hasMore;
  final String? selectedCategory;
  final String searchQuery;
  final String? errorMessage;

  ProductListState({
    this.isLoading = false,
    this.products = const [],
    this.currentPage = 1,
    this.hasMore = true,
    this.selectedCategory,
    this.searchQuery = '',
    this.errorMessage,
  });

  ProductListState copyWith({
    bool? isLoading,
    List<ProductItem>? products,
    int? currentPage,
    bool? hasMore,
    String? selectedCategory,
    String? searchQuery,
    String? errorMessage,
  }) {
    return ProductListState(
      isLoading: isLoading ?? this.isLoading,
      products: products ?? this.products,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage,
    );
  }
}

class ProductListNotifier extends StateNotifier<ProductListState> {
  final ProductApiService _apiService;

  ProductListNotifier(this._apiService) : super(ProductListState());

  /// Initial load or filter change
  Future<void> fetchProducts({String? categorySlug, String? search}) async {
    state = state.copyWith(
      isLoading: true,
      currentPage: 1,
      selectedCategory: categorySlug,
      searchQuery: search ?? '',
      errorMessage: null,
    );

    try {
      final res = await _apiService.getProducts(
        page: 1,
        categorySlug: categorySlug,
        search: search,
      );
      state = state.copyWith(
        isLoading: false,
        products: res.data,
        hasMore: res.currentPage < res.totalPages,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Load Next Page for Infinite Scroll
  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;

    final nextPage = state.currentPage + 1;
    try {
      final res = await _apiService.getProducts(
        page: nextPage,
        categorySlug: state.selectedCategory,
        search: state.searchQuery,
      );
      state = state.copyWith(
        products: [...state.products, ...res.data],
        currentPage: nextPage,
        hasMore: res.currentPage < res.totalPages,
      );
    } catch (e) {
      // Handle pagination silently or show snackbar
    }
  }
}
```

---

## 7. Product & Variant Business Logic Rules

1. **Variant Selection & Dynamic Price Display**:
   - Each product has one or more `variants` (e.g. 500g vs 1kg, Spicy vs Normal).
   - Use `defaultVariantId` or default to `variants.first.id` when opening product details.
   - Update displayed price & stock quantity dynamically in UI when customer picks a variant.

2. **Sale Pricing & Discount Banner**:
   - Check `isOnSale`: display `price` as current selling price, and draw a strikethrough line over `compareAtPrice`.
   - If `discountEndDate` is past current date, sale pricing is inactive.

3. **Verified Review Error**:
   - When a user tries to submit a review without having bought the item, backend returns HTTP 400: `Verified Purchase Required...`. Display a clear friendly dialog: *"You can only leave a review after purchasing and receiving this item."*
