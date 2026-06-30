part of '../cart_remote_datasource.dart';

abstract class CartRemoteDataSource {
  Future<List<CartItemModel>> getItems();
  Future<void> addItem({required String productId, required int quantity});
  Future<void> updateQuantity({required String itemId, required int quantity});
  Future<void> removeItem(String productId);
  Future<CartCouponModel> applyCoupon(String code);
  Future<void> clearCart();
}
