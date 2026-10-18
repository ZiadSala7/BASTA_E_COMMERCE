import '../../domain/entities/shipping_rate_entity.dart';

class ShippingRateModel extends ShippingRateEntity {
  const ShippingRateModel({
    required super.city,
    required super.shippingFee,
    super.estimatedDeliveryDays,
  });

  factory ShippingRateModel.fromJson(Map<String, dynamic> json) {
    final payload = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    final rawFee = payload['shippingFee'] ??
        payload['shipping_fee'] ??
        payload['fee'] ??
        payload['rate'];

    final fee = rawFee is num
        ? rawFee.toDouble()
        : double.tryParse(rawFee?.toString().trim() ?? '');

    if (fee == null || !fee.isFinite || fee < 0) {
      throw const FormatException(
        'Shipping response does not contain a valid shipping fee.',
      );
    }

    return ShippingRateModel(
      city: (payload['city'] ?? '').toString(),
      shippingFee: fee,
      estimatedDeliveryDays: (payload['estimatedDeliveryDays'] ??
              payload['estimated_delivery_days'] ??
              payload['deliveryDays'])
          ?.toString(),
    );
  }
}
