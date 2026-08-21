import '../entities/cart_coupon_entity.dart';
import '../entities/cart_data_entity.dart';
import '../entities/cart_item_entity.dart';

abstract class CartRepository {
  Future<CartDataEntity> getCart();
  Future<List<CartItemEntity>> getCartItems();
  Future<void> addItem({
    String? productId,
    String? variantId,
    int quantity = 1,
  });
  Future<void> addToCart(CartItemEntity item);
  Future<void> removeFromCart(String variantId);
  Future<void> updateQuantity(String variantId, int quantity);
  Future<CartCouponEntity> applyCoupon(String code);
  Future<double> getCartTotal();
  Future<void> clearCart();
}
