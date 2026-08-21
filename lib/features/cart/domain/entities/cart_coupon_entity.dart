class CartCouponEntity {
  final double cartTotal;
  final double discountAmount;
  final double finalTotal;
  final String appliedCoupon;
  final String message;

  const CartCouponEntity({
    required this.cartTotal,
    required this.discountAmount,
    required this.finalTotal,
    required this.appliedCoupon,
    required this.message,
  });

  CartCouponEntity copyWith({
    double? cartTotal,
    double? discountAmount,
    double? finalTotal,
    String? appliedCoupon,
    String? message,
  }) {
    return CartCouponEntity(
      cartTotal: cartTotal ?? this.cartTotal,
      discountAmount: discountAmount ?? this.discountAmount,
      finalTotal: finalTotal ?? this.finalTotal,
      appliedCoupon: appliedCoupon ?? this.appliedCoupon,
      message: message ?? this.message,
    );
  }
}
