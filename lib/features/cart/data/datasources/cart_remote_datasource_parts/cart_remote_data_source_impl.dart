part of '../cart_remote_datasource.dart';

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final DioConsumer _dioConsumer;

  const CartRemoteDataSourceImpl({required DioConsumer dioConsumer})
    : _dioConsumer = dioConsumer;

  @override
  Future<CartDataModel> getCart() async {
    try {
      final response = await _dioConsumer.get(Endpoints.cart);
      return CartDataModel.fromJson(_asMap(response.data));
    } on DioException catch (error, stackTrace) {
      log('Get cart request failed', error: error, stackTrace: stackTrace);
      throw Exception(_messageFromDio(error, fallback: 'Could not load cart.'));
    } catch (error, stackTrace) {
      log('Unexpected error getting cart', error: error, stackTrace: stackTrace);
      throw Exception('Could not load cart: $error');
    }
  }

  @override
  Future<List<CartItemModel>> getItems() async {
    final cart = await getCart();
    return cart.items.whereType<CartItemModel>().toList();
  }

  @override
  Future<dynamic> addItem({
    String? productId,
    String? variantId,
    int quantity = 1,
  }) async {
    final cleanVariantId = variantId?.trim();
    final cleanProductId = productId?.trim();

    if ((cleanVariantId == null || cleanVariantId.isEmpty) &&
        (cleanProductId == null || cleanProductId.isEmpty)) {
      throw Exception('Either variantId or productId must be provided');
    }

    try {
      final data = <String, dynamic>{
        if (cleanVariantId != null && cleanVariantId.isNotEmpty)
          'variantId': cleanVariantId,
        if (cleanProductId != null && cleanProductId.isNotEmpty)
          'productId': cleanProductId,
        'quantity': quantity,
      };

      final response = await _dioConsumer.post(
        Endpoints.cartItems,
        data: data,
      );
      final resData = _asMap(response.data);
      return resData['data'] ?? resData;
    } on DioException catch (error, stackTrace) {
      log('Add cart item request failed', error: error, stackTrace: stackTrace);
      throw Exception(
        _messageFromDio(error, fallback: 'Could not add product to cart.'),
      );
    }
  }

  @override
  Future<dynamic> updateQuantity({
    required String variantId,
    required int quantity,
  }) async {
    final cleanVariantId = variantId.trim();
    if (cleanVariantId.isEmpty) {
      throw Exception('Variant ID is required to update cart quantity.');
    }

    try {
      final response = await _dioConsumer.patch(
        Endpoints.cartItem(cleanVariantId),
        data: {'quantity': quantity},
      );
      final resData = _asMap(response.data);
      return resData['data'] ?? resData;
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
  Future<void> removeItem(String variantId) async {
    final cleanVariantId = variantId.trim();
    if (cleanVariantId.isEmpty) {
      throw Exception('Variant ID is required to remove item from cart.');
    }

    try {
      await _dioConsumer.delete(Endpoints.cartItem(cleanVariantId));
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
    final cleanCode = code.trim();
    if (cleanCode.isEmpty) {
      throw Exception('Coupon code cannot be empty.');
    }

    try {
      final response = await _dioConsumer.post(
        Endpoints.applyCoupon,
        data: {'code': cleanCode},
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
      if (message != null && message.trim().isNotEmpty) return message.trim();

      final errorValue = data['error']?.toString();
      if (errorValue != null && errorValue.trim().isNotEmpty) {
        return errorValue.trim();
      }
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
