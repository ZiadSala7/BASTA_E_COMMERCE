import '../repositories/payment_settings_repository.dart';

class IsCardPaymentEnabledUseCase {
  final PaymentSettingsRepository _repository;

  const IsCardPaymentEnabledUseCase({
    required PaymentSettingsRepository repository,
  }) : _repository = repository;

  Future<bool> call() {
    return _repository.isCardPaymentEnabled();
  }
}
