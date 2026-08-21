import '../../domain/entities/cart_coupon_entity.dart';
import '../../domain/entities/cart_data_entity.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_remote_datasource.dart';

class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource _remoteDataSource;

  const CartRepositoryImpl({required CartRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  @override
  Future<CartDataEntity> getCart() {
    return _remoteDataSource.getCart();
  }

  @override
  Future<List<CartItemEntity>> getCartItems() async {
    return _remoteDataSource.getItems();
  }

  @override
  Future<void> addItem({
    String? productId,
    String? variantId,
    int quantity = 1,
  }) {
    return _remoteDataSource.addItem(
      productId: productId,
      variantId: variantId,
      quantity: quantity,
    );
  }

  @override
  Future<void> addToCart(CartItemEntity item) {
    final cleanVariantId = item.variantId.trim();
    final cleanProductId = item.productId.trim();

    return addItem(
      variantId: cleanVariantId.isNotEmpty ? cleanVariantId : null,
      productId: cleanProductId.isNotEmpty
          ? cleanProductId
          : (cleanVariantId.isEmpty ? item.id : null),
      quantity: item.quantity,
    );
  }

  @override
  Future<void> removeFromCart(String variantId) {
    return _remoteDataSource.removeItem(variantId);
  }

  @override
  Future<void> updateQuantity(String variantId, int quantity) {
    if (quantity < 1) {
      return removeFromCart(variantId);
    }
    return _remoteDataSource.updateQuantity(
      variantId: variantId,
      quantity: quantity,
    );
  }

  @override
  Future<CartCouponEntity> applyCoupon(String code) {
    return _remoteDataSource.applyCoupon(code);
  }

  @override
  Future<double> getCartTotal() async {
    try {
      final cart = await getCart();
      return cart.cartTotal;
    } catch (_) {
      final items = await getCartItems();
      return items.fold<double>(
        0.0,
        (total, item) => total + (item.activePrice * item.quantity),
      );
    }
  }

  @override
  Future<void> clearCart() {
    return _remoteDataSource.clearCart();
  }
}
