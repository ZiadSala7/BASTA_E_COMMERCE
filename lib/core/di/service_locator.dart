import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/dio_consumer.dart';
import '../auth/session_token_store.dart';
import '../cache/cache_helper.dart';
import '../storage/secure_storage_service.dart';
import '../../features/account/data/datasources/account_remote_datasource.dart';
import '../../features/account/data/repositories/account_repository_impl.dart';
import '../../features/account/domain/repositories/account_repository.dart';
import '../../features/account/domain/usecases/get_account_stats_usecase.dart';
import '../../features/account/presentation/cubits/account_cubit.dart';
import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/change_password_usecase.dart';
import '../../features/auth/domain/usecases/confirm_email_usecase.dart';
import '../../features/auth/domain/usecases/forgot_password_usecase.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/domain/usecases/resend_confirmation_usecase.dart';
import '../../features/auth/domain/usecases/reset_password_usecase.dart';
import '../../features/auth/domain/usecases/update_profile_usecase.dart';
import '../../features/auth/presentation/cubits/auth_cubit.dart';
import '../../features/cart/data/datasources/cart_remote_datasource.dart';
import '../../features/cart/data/repositories/cart_repository_impl.dart';
import '../../features/cart/domain/repositories/cart_repository.dart';
import '../../features/cart/domain/services/cart_badge_controller.dart';
import '../../features/cart/domain/usecases/add_cart_item_usecase.dart';
import '../../features/cart/domain/usecases/get_cart_items_usecase.dart';
import '../../features/favorites/data/datasources/favorites_remote_datasource.dart';
import '../../features/favorites/domain/services/favorites_controller.dart';
import '../../features/home/data/datasources/home_catalog_remote_datasource.dart';
import '../../features/home/data/repositories/home_catalog_repository_impl.dart';
import '../../features/home/domain/repositories/home_catalog_repository.dart';
import '../../features/home/domain/usecases/get_home_categories_usecase.dart';
import '../../features/home/domain/usecases/get_home_products_usecase.dart';
import '../../features/home/domain/usecases/get_home_stores_usecase.dart';
import '../../features/onboarding/data/datasources/onboarding_local_datasource.dart';
import '../../features/onboarding/data/repositories/onboarding_repository_impl.dart';
import '../../features/onboarding/domain/repositories/onboarding_repository.dart';
import '../../features/onboarding/domain/usecases/complete_onboarding_usecase.dart';
import '../../features/onboarding/domain/usecases/get_onboarding_pages_usecase.dart';
import '../../features/onboarding/presentation/bloc/onboarding_bloc.dart';
import '../../features/orders/data/datasources/orders_remote_datasource.dart';
import '../../features/orders/data/repositories/orders_repository_impl.dart';
import '../../features/orders/domain/repositories/orders_repository.dart';
import '../../features/orders/domain/usecases/get_my_orders_usecase.dart';
import '../../features/products/data/datasources/product_reviews_remote_datasource.dart';
import '../../features/products/domain/usecases/add_product_review_usecase.dart';
import '../../features/products/domain/usecases/get_product_reviews_usecase.dart';
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
    getIt.registerLazySingleton<SecureStorageService>(SecureStorageService.new);
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
      AuthRepositoryImpl(remoteDataSource: getIt(), localDataSource: getIt()),
    );
  }

  if (!getIt.isRegistered<LoginUseCase>()) {
    getIt.registerLazySingleton<LoginUseCase>(() => LoginUseCase(getIt()));
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

  if (!getIt.isRegistered<ConfirmEmailUseCase>()) {
    getIt.registerLazySingleton<ConfirmEmailUseCase>(
      () => ConfirmEmailUseCase(getIt()),
    );
  }

  if (!getIt.isRegistered<ResendConfirmationUseCase>()) {
    getIt.registerLazySingleton<ResendConfirmationUseCase>(
      () => ResendConfirmationUseCase(getIt()),
    );
  }

  if (!getIt.isRegistered<ResetPasswordUseCase>()) {
    getIt.registerLazySingleton<ResetPasswordUseCase>(
      () => ResetPasswordUseCase(getIt()),
    );
  }

  if (!getIt.isRegistered<ChangePasswordUseCase>()) {
    getIt.registerLazySingleton<ChangePasswordUseCase>(
      () => ChangePasswordUseCase(getIt()),
    );
  }

  if (!getIt.isRegistered<UpdateProfileUseCase>()) {
    getIt.registerLazySingleton<UpdateProfileUseCase>(
      () => UpdateProfileUseCase(getIt()),
    );
  }

  if (!getIt.isRegistered<GetCurrentUserUseCase>()) {
    getIt.registerLazySingleton<GetCurrentUserUseCase>(
      () => GetCurrentUserUseCase(getIt()),
    );
  }

  if (!getIt.isRegistered<LogoutUseCase>()) {
    getIt.registerLazySingleton<LogoutUseCase>(() => LogoutUseCase(getIt()));
  }

  if (!getIt.isRegistered<AuthCubit>()) {
    getIt.registerFactory<AuthCubit>(
      () => AuthCubit(
        loginUseCase: getIt(),
        registerUseCase: getIt(),
        confirmEmailUseCase: getIt(),
        resendConfirmationUseCase: getIt(),
        forgotPasswordUseCase: getIt(),
        resetPasswordUseCase: getIt(),
        changePasswordUseCase: getIt(),
        updateProfileUseCase: getIt(),
        getCurrentUserUseCase: getIt(),
        logoutUseCase: getIt(),
      ),
    );
  }

  if (!getIt.isRegistered<CartRemoteDataSource>()) {
    getIt.registerLazySingleton<CartRemoteDataSource>(
      () => CartRemoteDataSourceImpl(dioConsumer: getIt()),
    );
  }

  if (!getIt.isRegistered<CartRepository>()) {
    getIt.registerLazySingleton<CartRepository>(
      () => CartRepositoryImpl(remoteDataSource: getIt()),
    );
  }

  if (!getIt.isRegistered<CartBadgeController>()) {
    getIt.registerLazySingleton<CartBadgeController>(
      () => CartBadgeController(getIt()),
    );
  }

  if (!getIt.isRegistered<AddCartItemUseCase>()) {
    getIt.registerLazySingleton<AddCartItemUseCase>(
      () => AddCartItemUseCase(getIt(), getIt()),
    );
  }

  if (!getIt.isRegistered<GetCartItemsUseCase>()) {
    getIt.registerLazySingleton<GetCartItemsUseCase>(
      () => GetCartItemsUseCase(getIt()),
    );
  }

  if (!getIt.isRegistered<FavoritesRemoteDataSource>()) {
    getIt.registerLazySingleton<FavoritesRemoteDataSource>(
      () => FavoritesRemoteDataSourceImpl(dioConsumer: getIt()),
    );
  }

  if (!getIt.isRegistered<FavoritesController>()) {
    getIt.registerLazySingleton<FavoritesController>(
      () => FavoritesController(getIt()),
    );
  }

  if (!getIt.isRegistered<HomeCatalogRemoteDataSource>()) {
    getIt.registerLazySingleton<HomeCatalogRemoteDataSource>(
      () => HomeCatalogRemoteDataSourceImpl(dioConsumer: getIt()),
    );
  }

  if (!getIt.isRegistered<HomeCatalogRepository>()) {
    getIt.registerLazySingleton<HomeCatalogRepository>(
      () => HomeCatalogRepositoryImpl(remoteDataSource: getIt()),
    );
  }

  if (!getIt.isRegistered<GetHomeCategoriesUseCase>()) {
    getIt.registerLazySingleton<GetHomeCategoriesUseCase>(
      () => GetHomeCategoriesUseCase(getIt()),
    );
  }

  if (!getIt.isRegistered<GetHomeProductsUseCase>()) {
    getIt.registerLazySingleton<GetHomeProductsUseCase>(
      () => GetHomeProductsUseCase(getIt()),
    );
  }

  if (!getIt.isRegistered<GetHomeStoresUseCase>()) {
    getIt.registerLazySingleton<GetHomeStoresUseCase>(
      () => GetHomeStoresUseCase(getIt()),
    );
  }

  if (!getIt.isRegistered<ProductReviewsRemoteDataSource>()) {
    getIt.registerLazySingleton<ProductReviewsRemoteDataSource>(
      () => ProductReviewsRemoteDataSourceImpl(dioConsumer: getIt()),
    );
  }

  if (!getIt.isRegistered<GetProductReviewsUseCase>()) {
    getIt.registerLazySingleton<GetProductReviewsUseCase>(
      () => GetProductReviewsUseCase(getIt()),
    );
  }

  if (!getIt.isRegistered<AddProductReviewUseCase>()) {
    getIt.registerLazySingleton<AddProductReviewUseCase>(
      () => AddProductReviewUseCase(getIt()),
    );
  }

  if (!getIt.isRegistered<OrdersRemoteDataSource>()) {
    getIt.registerLazySingleton<OrdersRemoteDataSource>(
      () => OrdersRemoteDataSourceImpl(dioConsumer: getIt()),
    );
  }

  if (!getIt.isRegistered<OrdersRepository>()) {
    getIt.registerLazySingleton<OrdersRepository>(
      () => OrdersRepositoryImpl(remoteDataSource: getIt()),
    );
  }

  if (!getIt.isRegistered<GetMyOrdersUseCase>()) {
    getIt.registerLazySingleton<GetMyOrdersUseCase>(
      () => GetMyOrdersUseCase(getIt()),
    );
  }

  if (!getIt.isRegistered<AccountRemoteDataSource>()) {
    getIt.registerLazySingleton<AccountRemoteDataSource>(
      () => AccountRemoteDataSourceImpl(dioConsumer: getIt()),
    );
  }

  if (!getIt.isRegistered<AccountRepository>()) {
    getIt.registerLazySingleton<AccountRepository>(
      () => AccountRepositoryImpl(remoteDataSource: getIt()),
    );
  }

  if (!getIt.isRegistered<GetAccountStatsUseCase>()) {
    getIt.registerLazySingleton<GetAccountStatsUseCase>(
      () => GetAccountStatsUseCase(getIt()),
    );
  }

  if (!getIt.isRegistered<AccountCubit>()) {
    getIt.registerFactory<AccountCubit>(
      () => AccountCubit(getAccountStatsUseCase: getIt()),
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
