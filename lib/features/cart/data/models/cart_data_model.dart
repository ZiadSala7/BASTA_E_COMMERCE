import '../../domain/entities/cart_data_entity.dart';
import 'cart_item_model.dart';

class CartDataModel extends CartDataEntity {
  const CartDataModel({
    super.cartId,
    required super.cartTotal,
    required List<CartItemModel> super.items,
  });

  factory CartDataModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final payload = rawData is Map<String, dynamic>
        ? rawData
        : (rawData is Map ? Map<String, dynamic>.from(rawData) : json);

    final rawItems =
        payload['items'] ?? payload['cartItems'] ?? payload['products'];
    final itemsList = (rawItems is List ? rawItems : const <dynamic>[])
        .whereType<Map>()
        .map((item) => CartItemModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();

    final rawTotal = payload['cartTotal'] ??
        payload['cart_total'] ??
        payload['total'] ??
        payload['subtotal'];
    final cartTotal = (rawTotal is num)
        ? rawTotal.toDouble()
        : (double.tryParse((rawTotal ?? '').toString().trim()) ??
            itemsList.fold<double>(
              0.0,
              (sum, item) => sum + (item.activePrice * item.quantity),
            ));

    return CartDataModel(
      cartId: payload['cartId']?.toString() ??
          payload['cart_id']?.toString() ??
          payload['id']?.toString(),
      cartTotal: cartTotal,
      items: itemsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cartId': cartId,
      'cartTotal': cartTotal,
      'items': items
          .map((item) => (item is CartItemModel) ? item.toJson() : null)
          .whereType<Map<String, dynamic>>()
          .toList(),
    };
  }
}
