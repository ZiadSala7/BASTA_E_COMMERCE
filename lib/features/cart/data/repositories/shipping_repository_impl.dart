import '../../domain/entities/shipping_rate_entity.dart';
import '../../domain/repositories/shipping_repository.dart';
import '../datasources/shipping_remote_datasource.dart';

class ShippingRepositoryImpl implements ShippingRepository {
  final ShippingRemoteDataSource _remoteDataSource;

  const ShippingRepositoryImpl({
    required ShippingRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<ShippingRateEntity> calculateShipping({
    required String city,
    String? streetAddress,
  }) {
    return _remoteDataSource.calculateShipping(
      city: city,
      streetAddress: streetAddress,
    );
  }
}
