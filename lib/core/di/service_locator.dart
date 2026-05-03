import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/dio_consumer.dart';
import '../auth/session_token_store.dart';
import '../cache/cache_helper.dart';
import '../storage/secure_storage_service.dart';
import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/forgot_password_usecase.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/presentation/cubits/auth_cubit.dart';
import '../../features/onboarding/data/datasources/onboarding_local_datasource.dart';
import '../../features/onboarding/data/repositories/onboarding_repository_impl.dart';
import '../../features/onboarding/domain/repositories/onboarding_repository.dart';
import '../../features/onboarding/domain/usecases/complete_onboarding_usecase.dart';
import '../../features/onboarding/domain/usecases/get_onboarding_pages_usecase.dart';
import '../../features/onboarding/presentation/bloc/onboarding_bloc.dart';
import '../../features/splash/data/datasources/splash_local_datasource.dart';
import '../../features/splash/data/repositories/splash_repository_impl.dart';
import '../../features/splash/domain/repositories/splash_repository.dart';
import '../../features/splash/domain/usecases/get_initial_route_usecase.dart';
import '../../features/splash/presentation/bloc/splash_bloc.dart';

final getIt = GetIt.instance;
final sl = getIt;

void setupServiceLocator() {
  // Register DioConsumer as singleton
  if (!getIt.isRegistered<DioConsumer>()) {
    getIt.registerSingleton<DioConsumer>(DioConsumer());
  }

  if (!getIt.isRegistered<SharedPreferences>()) {
    getIt.registerSingleton<SharedPreferences>(CacheHelper.instance);
  }

  if (!getIt.isRegistered<SecureStorageService>()) {
    getIt.registerLazySingleton<SecureStorageService>(
      SecureStorageService.new,
    );
  }

  if (!getIt.isRegistered<AuthLocalDataSource>()) {
    getIt.registerLazySingleton<AuthLocalDataSource>(
      () => AuthLocalDataSourceImpl(secureStorageService: getIt()),
    );
  }

  if (!getIt.isRegistered<SessionTokenStore>()) {
    getIt.registerLazySingleton<SessionTokenStore>(
      () => getIt<AuthLocalDataSource>(),
    );
  }

  if (!getIt.isRegistered<AuthRemoteDataSource>()) {
    getIt.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(dioConsumer: getIt()),
    );
  }

  // Register repositories
  if (!getIt.isRegistered<AuthRepository>()) {
    getIt.registerSingleton<AuthRepository>(
      AuthRepositoryImpl(
        remoteDataSource: getIt(),
        sessionTokenStore: getIt(),
      ),
    );
  }

  if (!getIt.isRegistered<LoginUseCase>()) {
    getIt.registerLazySingleton<LoginUseCase>(
      () => LoginUseCase(getIt()),
    );
  }

  if (!getIt.isRegistered<RegisterUseCase>()) {
    getIt.registerLazySingleton<RegisterUseCase>(
      () => RegisterUseCase(getIt()),
    );
  }

  if (!getIt.isRegistered<ForgotPasswordUseCase>()) {
    getIt.registerLazySingleton<ForgotPasswordUseCase>(
      () => ForgotPasswordUseCase(getIt()),
    );
  }

  if (!getIt.isRegistered<GetCurrentUserUseCase>()) {
    getIt.registerLazySingleton<GetCurrentUserUseCase>(
      () => GetCurrentUserUseCase(getIt()),
    );
  }

  if (!getIt.isRegistered<LogoutUseCase>()) {
    getIt.registerLazySingleton<LogoutUseCase>(
      () => LogoutUseCase(getIt()),
    );
  }

  if (!getIt.isRegistered<AuthCubit>()) {
    getIt.registerFactory<AuthCubit>(
      () => AuthCubit(
        loginUseCase: getIt(),
        registerUseCase: getIt(),
        forgotPasswordUseCase: getIt(),
        getCurrentUserUseCase: getIt(),
        logoutUseCase: getIt(),
      ),
    );
  }

  if (!getIt.isRegistered<OnboardingLocalDataSource>()) {
    getIt.registerLazySingleton<OnboardingLocalDataSource>(
      () => OnboardingLocalDataSourceImpl(prefs: getIt()),
    );
  }

  if (!getIt.isRegistered<OnboardingRepository>()) {
    getIt.registerLazySingleton<OnboardingRepository>(
      () => OnboardingRepositoryImpl(localDataSource: getIt()),
    );
  }

  if (!getIt.isRegistered<GetOnboardingPagesUseCase>()) {
    getIt.registerLazySingleton<GetOnboardingPagesUseCase>(
      () => GetOnboardingPagesUseCase(getIt()),
    );
  }

  if (!getIt.isRegistered<CompleteOnboardingUseCase>()) {
    getIt.registerLazySingleton<CompleteOnboardingUseCase>(
      () => CompleteOnboardingUseCase(getIt()),
    );
  }

  if (!getIt.isRegistered<OnboardingBloc>()) {
    getIt.registerFactory<OnboardingBloc>(
      () => OnboardingBloc(
        getOnboardingPages: getIt(),
        completeOnboarding: getIt(),
      ),
    );
  }

  if (!getIt.isRegistered<SplashLocalDataSource>()) {
    getIt.registerLazySingleton<SplashLocalDataSource>(
      () => SplashLocalDataSourceImpl(
        onboardingLocalDataSource: getIt(),
        sessionTokenStore: getIt(),
      ),
    );
  }

  if (!getIt.isRegistered<SplashRepository>()) {
    getIt.registerLazySingleton<SplashRepository>(
      () => SplashRepositoryImpl(localDataSource: getIt()),
    );
  }

  if (!getIt.isRegistered<GetInitialRouteUseCase>()) {
    getIt.registerLazySingleton<GetInitialRouteUseCase>(
      () => GetInitialRouteUseCase(getIt()),
    );
  }

  if (!getIt.isRegistered<SplashBloc>()) {
    getIt.registerFactory<SplashBloc>(
      () => SplashBloc(getInitialRoute: getIt()),
    );
  }
}
