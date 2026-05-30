import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/main/presentation/pages/main_navigation_page.dart';
import '../di/service_locator.dart';
import '../../features/auth/presentation/cubits/auth_cubit.dart';
import '../../features/auth/presentation/models/auth_verification_args.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/auth/presentation/pages/verification_page.dart';
import '../../features/cart/presentation/pages/enhanced_checkout_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/home/presentation/pages/stores_listing_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/products/presentation/pages/product_detail_page.dart';
import '../../features/products/presentation/pages/products_listing_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';

abstract class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String verification = '/auth/verification';
  static const String home = '/home';
  static const String mainNavigation = '/mainNavigation';
  static const String notifications = '/notifications';
  static const String products = '/products';
  static const String stores = '/stores';
  static const String productDetail = '/product-detail';
  static const String checkout = '/checkout';
}

class AppRouter {
  AppRouter();

  final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => BlocProvider(
          create: (_) => sl<AuthCubit>(),
          child: const LoginPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => BlocProvider(
          create: (_) => sl<AuthCubit>(),
          child: const RegisterPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => BlocProvider(
          create: (_) => sl<AuthCubit>(),
          child: const ForgotPasswordPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        builder: (context, state) => BlocProvider(
          create: (_) => sl<AuthCubit>(),
          child: ResetPasswordPage(
            arguments: state.extra as AuthPasswordResetArgs?,
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.verification,
        builder: (context, state) => BlocProvider(
          create: (_) => sl<AuthCubit>(),
          child: VerificationPage(
            arguments:
                state.extra as AuthVerificationArgs? ??
                const AuthVerificationArgs.passwordReset(destination: ''),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutes.mainNavigation,
        builder: (context, state) => const MainNavigationPage(),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, state) => const NotificationsPage(),
      ),
      GoRoute(
        path: AppRoutes.products,
        builder: (context, state) {
          final extra = state.extra;
          final args = extra is ProductsListingArgs
              ? extra
              : ProductsListingArgs(title: extra is String ? extra : null);

          return ProductsListingPage(args: args);
        },
      ),
      GoRoute(
        path: AppRoutes.stores,
        builder: (context, state) => const StoresListingPage(),
      ),
      GoRoute(
        path: AppRoutes.productDetail,
        builder: (context, state) {
          final extra = state.extra;
          final product = extra is ProductDetailArgs ? extra : null;
          final productId = product?.id ?? (extra is String ? extra : '');

          return ProductDetailPage(productId: productId, product: product);
        },
      ),
      GoRoute(
        path: AppRoutes.checkout,
        builder: (context, state) => const EnhancedCheckoutPage(),
      ),
    ],
  );
}
