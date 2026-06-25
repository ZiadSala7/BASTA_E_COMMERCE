import '../../domain/entities/cart_item_entity.dart';
import '../../domain/entities/cart_coupon_entity.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_remote_datasource.dart';

class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource _remoteDataSource;

  const CartRepositoryImpl({required CartRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  @override
  Future<void> addItem({required String productId, required int quantity}) {
    return _remoteDataSource.addItem(productId: productId, quantity: quantity);
  }

  @override
  Future<void> addToCart(CartItemEntity item) {
    final productId = item.productId.isEmpty ? item.id : item.productId;
    return addItem(productId: productId, quantity: item.quantity);
  }

  @override
  Future<void> clearCart() {
    return _remoteDataSource.clearCart();
  }

  @override
  Future<List<CartItemEntity>> getCartItems() async {
    return _remoteDataSource.getItems();
  }

  @override
  Future<double> getCartTotal() async {
    final items = await getCartItems();
    return items.fold<double>(
      0,
      (total, item) => total + (item.activePrice * item.quantity),
    );
  }

  @override
  Future<void> removeFromCart(String productId) {
    return _remoteDataSource.removeItem(productId);
  }

  @override
  Future<void> updateQuantity(String itemId, int quantity) {
    return _remoteDataSource.updateQuantity(itemId: itemId, quantity: quantity);
  }

  @override
  Future<CartCouponEntity> applyCoupon(String code) {
    return _remoteDataSource.applyCoupon(code);
  }
}
