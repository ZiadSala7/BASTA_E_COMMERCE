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
}
