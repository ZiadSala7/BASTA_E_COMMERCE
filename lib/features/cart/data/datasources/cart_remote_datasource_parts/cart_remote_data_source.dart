part of '../cart_remote_datasource.dart';

abstract class CartRemoteDataSource {
  Future<CartDataModel> getCart();
  Future<List<CartItemModel>> getItems();
  Future<dynamic> addItem({
    String? productId,
    String? variantId,
    int quantity = 1,
  });
  Future<dynamic> updateQuantity({
    required String variantId,
    required int quantity,
  });
  Future<void> removeItem(String variantId);
  Future<CartCouponModel> applyCoupon(String code);
  Future<void> clearCart();
}
