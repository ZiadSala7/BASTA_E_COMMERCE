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
    final rawData = json['data'];
    final payload = rawData is Map<String, dynamic>
        ? rawData
        : (rawData is Map ? Map<String, dynamic>.from(rawData) : json);

    return CartCouponModel(
      cartTotal: _number(
        payload['cartTotal'] ?? payload['cart_total'] ?? payload['total'],
      ),
      discountAmount: _number(
        payload['discountAmount'] ??
            payload['discount_amount'] ??
            payload['discount'],
      ),
      finalTotal: _number(
        payload['finalTotal'] ??
            payload['final_total'] ??
            payload['netTotal'],
      ),
      appliedCoupon: (payload['appliedCoupon'] ??
              payload['applied_coupon'] ??
              payload['code'] ??
              '')
          .toString()
          .trim(),
      message: (payload['message'] ??
              json['message'] ??
              'Coupon applied successfully!')
          .toString()
          .trim(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cartTotal': cartTotal,
      'discountAmount': discountAmount,
      'finalTotal': finalTotal,
      'appliedCoupon': appliedCoupon,
      'message': message,
    };
  }

  static double _number(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse((value ?? '').toString().trim()) ?? 0.0;
  }
}
