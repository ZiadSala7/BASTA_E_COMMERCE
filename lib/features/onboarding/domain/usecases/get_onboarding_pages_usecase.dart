import '../entities/onboarding_page_entity.dart';
import '../repositories/onboarding_repository.dart';

class GetOnboardingPagesUseCase {
  final OnboardingRepository _repository;
  const GetOnboardingPagesUseCase(this._repository);

  Future<List<OnboardingPageEntity>> call() => _repository.getOnboardingPages();
}
