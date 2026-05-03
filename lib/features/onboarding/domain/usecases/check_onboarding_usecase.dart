import '../repositories/onboarding_repository.dart';

class CheckOnboardingUseCase {
  final OnboardingRepository _repository;
  const CheckOnboardingUseCase(this._repository);

  Future<bool> call() => _repository.isOnboardingCompleted();
}
