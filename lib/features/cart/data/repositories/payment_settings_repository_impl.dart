import '../../domain/repositories/payment_settings_repository.dart';
import '../datasources/payment_settings_remote_datasource.dart';

class PaymentSettingsRepositoryImpl implements PaymentSettingsRepository {
  final PaymentSettingsRemoteDataSource _remoteDataSource;

  const PaymentSettingsRepositoryImpl({
    required PaymentSettingsRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<bool> isCardPaymentEnabled() {
    return _remoteDataSource.isCardPaymentEnabled();
  }
}
