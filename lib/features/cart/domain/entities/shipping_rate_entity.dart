class ShippingRateEntity {
  final String city;
  final double shippingFee;
  final String? estimatedDeliveryDays;

  const ShippingRateEntity({
    required this.city,
    required this.shippingFee,
    this.estimatedDeliveryDays,
  });
}
