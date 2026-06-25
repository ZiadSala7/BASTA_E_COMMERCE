import '../../domain/entities/cart_coupon_entity.dart';

class CartCouponModel extends CartCouponEntity {
  const CartCouponModel({
    required super.cartTotal,
    required super.discountAmount,
    required super.finalTotal,
    required super.appliedCoupon,
    required super.message,
  });

  factory CartCouponModel.fromJson(Map<String, dynamic> json) {
    final data = _asMap(json['data']);
    final payload = data.isEmpty ? json : data;

    return CartCouponModel(
      cartTotal: _number(payload['cartTotal']),
      discountAmount: _number(payload['discountAmount']),
      finalTotal: _number(payload['finalTotal']),
      appliedCoupon: (payload['appliedCoupon'] ?? '').toString(),
      message: (payload['message'] ?? json['message'] ?? 'Coupon applied')
          .toString(),
    );
  }

  static Map<String, dynamic> _asMap(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, item) => MapEntry(key.toString(), item));
    }
    return <String, dynamic>{};
  }

  static double _number(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse((value ?? '').toString()) ?? 0;
  }
}
