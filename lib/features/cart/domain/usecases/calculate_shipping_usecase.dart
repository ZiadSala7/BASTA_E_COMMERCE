import '../entities/shipping_rate_entity.dart';
import '../repositories/shipping_repository.dart';

class CalculateShippingUseCase {
  final ShippingRepository _repository;

  const CalculateShippingUseCase({required ShippingRepository repository})
      : _repository = repository;

  Future<ShippingRateEntity> call({
    required String city,
    String? streetAddress,
  }) {
    return _repository.calculateShipping(
      city: city,
      streetAddress: streetAddress,
    );
  }
}
