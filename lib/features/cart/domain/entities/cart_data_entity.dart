import 'cart_item_entity.dart';

class CartDataEntity {
  final String? cartId;
  final double cartTotal;
  final List<CartItemEntity> items;

  const CartDataEntity({
    this.cartId,
    required this.cartTotal,
    required this.items,
  });

  int get totalItemCount =>
      items.fold<int>(0, (sum, item) => sum + item.quantity);
}
