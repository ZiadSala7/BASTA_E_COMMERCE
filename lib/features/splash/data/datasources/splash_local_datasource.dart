import '../../../../core/auth/session_token_store.dart';
import '../../../../core/utils/app_router.dart';
import '../../../onboarding/data/datasources/onboarding_local_datasource.dart';
import '../models/splash_model.dart';

abstract class SplashLocalDataSource {
  Future<SplashModel> getSplashData();
}

class SplashLocalDataSourceImpl implements SplashLocalDataSource {
  final OnboardingLocalDataSource _onboardingLocalDataSource;
  final SessionTokenStore _sessionTokenStore;

  const SplashLocalDataSourceImpl({
    required OnboardingLocalDataSource onboardingLocalDataSource,
    required SessionTokenStore sessionTokenStore,
  }) : _onboardingLocalDataSource = onboardingLocalDataSource,
       _sessionTokenStore = sessionTokenStore;

  @override
  Future<SplashModel> getSplashData() async {
    await Future.delayed(const Duration(milliseconds: 100));

    final isOnboardingCompleted = await _onboardingLocalDataSource
        .isOnboardingCompleted();
    final hasToken = await _sessionTokenStore.hasToken();

    return SplashModel(
      initialRoute: isOnboardingCompleted
          ? (hasToken ? AppRoutes.mainNavigation : AppRoutes.login)
          : AppRoutes.onboarding,
      isFirstLaunch: !isOnboardingCompleted,
    );
  }
}
