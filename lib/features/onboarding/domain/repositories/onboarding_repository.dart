import '../entities/onboarding_page_entity.dart';

abstract class OnboardingRepository {
  Future<List<OnboardingPageEntity>> getOnboardingPages();
  Future<void> markOnboardingCompleted();
  Future<bool> isOnboardingCompleted();
}
