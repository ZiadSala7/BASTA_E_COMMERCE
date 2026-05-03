import '../../domain/entities/onboarding_page_entity.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../datasources/onboarding_local_datasource.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  final OnboardingLocalDataSource localDataSource;
  const OnboardingRepositoryImpl({required this.localDataSource});

  @override
  Future<List<OnboardingPageEntity>> getOnboardingPages() =>
      localDataSource.getOnboardingPages();

  @override
  Future<void> markOnboardingCompleted() =>
      localDataSource.markOnboardingCompleted();

  @override
  Future<bool> isOnboardingCompleted() =>
      localDataSource.isOnboardingCompleted();
}
