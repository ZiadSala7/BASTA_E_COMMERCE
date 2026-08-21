import '../entities/shipping_rate_entity.dart';

abstract class ShippingRepository {
  Future<ShippingRateEntity> calculateShipping({
    required String city,
    String? streetAddress,
  });
}
