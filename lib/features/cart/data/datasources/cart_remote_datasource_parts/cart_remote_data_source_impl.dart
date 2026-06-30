part of '../cart_remote_datasource.dart';

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final DioConsumer _dioConsumer;

  const CartRemoteDataSourceImpl({required DioConsumer dioConsumer})
    : _dioConsumer = dioConsumer;

  @override
  Future<List<CartItemModel>> getItems() async {
    try {
      final response = await _dioConsumer.get(Endpoints.cart);
      return _dataList(response.data)
          .whereType<Map>()
          .map(
            (item) => CartItemModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    } on DioException catch (error, stackTrace) {
      log('Get cart request failed', error: error, stackTrace: stackTrace);
      throw Exception(_messageFromDio(error, fallback: 'Could not load cart.'));
    }
  }

  @override
  Future<void> addItem({
    required String productId,
    required int quantity,
  }) async {
    try {
      await _dioConsumer.post(
        Endpoints.cartItems,
        data: {'productId': productId, 'quantity': quantity},
      );
    } on DioException catch (error, stackTrace) {
      log('Add cart item request failed', error: error, stackTrace: stackTrace);
      throw Exception(
        _messageFromDio(error, fallback: 'Could not add product to cart.'),
      );
    }
  }

  @override
  Future<void> updateQuantity({
    required String itemId,
    required int quantity,
  }) async {
    try {
      await _dioConsumer.patch(
        Endpoints.cartItem(itemId),
        data: {'quantity': quantity},
      );
    } on DioException catch (error, stackTrace) {
      log(
        'Update cart item request failed',
        error: error,
        stackTrace: stackTrace,
      );
      throw Exception(
        _messageFromDio(error, fallback: 'Could not update cart item.'),
      );
    }
  }

  @override
  Future<void> removeItem(String productId) async {
    try {
      await _dioConsumer.delete(Endpoints.cartItem(productId));
    } on DioException catch (error, stackTrace) {
      log(
        'Remove cart item request failed',
        error: error,
        stackTrace: stackTrace,
      );
      throw Exception(
        _messageFromDio(error, fallback: 'Could not remove cart item.'),
      );
    }
  }

  @override
  Future<CartCouponModel> applyCoupon(String code) async {
    try {
      final response = await _dioConsumer.post(
        Endpoints.applyCoupon,
        data: {'code': code},
      );

      return CartCouponModel.fromJson(_asMap(response.data));
    } on DioException catch (error, stackTrace) {
      log('Apply coupon request failed', error: error, stackTrace: stackTrace);
      throw Exception(
        _messageFromDio(error, fallback: 'Could not apply coupon.'),
      );
    }
  }

  @override
  Future<void> clearCart() async {
    try {
      await _dioConsumer.delete(Endpoints.cart);
    } on DioException catch (error, stackTrace) {
      log('Clear cart request failed', error: error, stackTrace: stackTrace);
      throw Exception(
        _messageFromDio(error, fallback: 'Could not clear cart.'),
      );
    }
  }

  List<dynamic> _dataList(dynamic data) {
    if (data is Map<String, dynamic>) {
      final directItems = data['items'] ?? data['cartItems'];
      if (directItems is List) return directItems;

      final body = data['body'];
      if (body is List) return body;
      if (body is Map<String, dynamic>) {
        final bodyItems =
            body['items'] ?? body['cartItems'] ?? body['products'];
        if (bodyItems is List) return bodyItems;

        final cart = body['cart'];
        if (cart is Map<String, dynamic>) {
          final cartItems = cart['items'] ?? cart['cartItems'];
          if (cartItems is List) return cartItems;
        }
      }

      final nested = data['data'];
      if (nested is List) return nested;
      if (nested is Map<String, dynamic>) {
        final nestedItems =
            nested['items'] ?? nested['cartItems'] ?? nested['products'];
        if (nestedItems is List) return nestedItems;

        final cart = nested['cart'];
        if (cart is Map<String, dynamic>) {
          final cartItems = cart['items'] ?? cart['cartItems'];
          if (cartItems is List) return cartItems;
        }
      }

      final cart = data['cart'];
      if (cart is Map<String, dynamic>) {
        final cartItems = cart['items'] ?? cart['cartItems'];
        if (cartItems is List) return cartItems;
      }
    }

    if (data is Map) {
      return _dataList(Map<String, dynamic>.from(data));
    }

    if (data is List) return data;
    return const <dynamic>[];
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) {
      return data.map((key, value) => MapEntry(key.toString(), value));
    }
    return <String, dynamic>{};
  }

  String _messageFromDio(DioException error, {required String fallback}) {
    final data = error.response?.data;
    if (data is Map) {
      final message = data['message']?.toString();
      if (message != null && message.isNotEmpty) return message;

      final errorValue = data['error']?.toString();
      if (errorValue != null && errorValue.isNotEmpty) return errorValue;
    }

    if (error.response?.statusCode == 401) {
      return 'Please log in to view your cart.';
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return 'The server took too long to respond. Please try again.';
    }

    if (error.type == DioExceptionType.connectionError) {
      return 'Unable to reach the server. Check your internet connection.';
    }

    return error.message ?? fallback;
  }
}
