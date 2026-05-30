import '../entities/cart_item_entity.dart';

abstract class CartRepository {
  Future<List<CartItemEntity>> getCartItems();
  Future<void> addItem({required String productId, required int quantity});
  Future<void> addToCart(CartItemEntity item);
  Future<void> removeFromCart(String productId);
  Future<void> updateQuantity(String itemId, int quantity);
  Future<double> getCartTotal();
  Future<void> clearCart();
}
