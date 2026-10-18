import 'package:busta/core/utils/app_navigation.dart';
import 'package:busta/core/utils/app_route_observer.dart';
import 'package:busta/core/widgets/app_bottom_navigation_shell.dart';
import 'package:busta/features/cart/domain/repositories/cart_repository.dart';
import 'package:busta/features/cart/domain/services/cart_badge_controller.dart';
import 'package:busta/features/home/presentation/widgets/home_bottom_nav_bar.dart';
import 'package:busta/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('keeps the bottom navigation visible across routes', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/detail',
      routes: [
        for (final path in [
          '/detail',
          '/mainNavigation',
          '/coupons',
          '/orders',
          '/cart',
          '/account',
        ])
          GoRoute(
            path: path,
            builder: (context, state) =>
                Scaffold(body: Center(child: Text(path))),
          ),
      ],
    );
    final cartBadgeController = CartBadgeController(_CartRepositoryStub());

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        theme: ThemeData(scaffoldBackgroundColor: Colors.green),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        builder: (context, child) => AppBottomNavigationShell(
          router: router,
          cartBadgeController: cartBadgeController,
          child: child!,
        ),
      ),
    );

    expect(find.text('/detail'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) => widget is ColoredBox && widget.color == Colors.green,
      ),
      findsOneWidget,
    );
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Coupons'), findsOneWidget);
    expect(find.text('My orders'), findsOneWidget);
    expect(find.text('Cart'), findsOneWidget);
    expect(find.text('My account'), findsOneWidget);

    await tester.tap(find.text('Coupons'));
    await tester.pumpAndSettle();

    expect(find.text('/coupons'), findsOneWidget);
    expect(find.text('Coupons'), findsOneWidget);

    await tester.tap(find.text('Cart'));
    await tester.pumpAndSettle();

    expect(find.text('/cart'), findsOneWidget);
    expect(find.text('Cart'), findsOneWidget);
  });

  testWidgets('does not duplicate the main screen bottom navigation', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/mainNavigation',
      routes: [
        GoRoute(
          path: '/mainNavigation',
          builder: (context, state) => const Scaffold(body: Text('Main')),
        ),
      ],
    );
    final cartBadgeController = CartBadgeController(_CartRepositoryStub());

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        builder: (context, child) => AppBottomNavigationShell(
          router: router,
          cartBadgeController: cartBadgeController,
          child: child!,
        ),
      ),
    );

    expect(find.text('Main'), findsOneWidget);
    expect(find.text('Coupons'), findsNothing);
  });

  testWidgets('does not duplicate bottom navigation after opening product detail and popping it via Navigator', (tester) async {
    final routeObserver = AppRouteObserver(initialRoute: '/mainNavigation');
    final router = GoRouter(
      initialLocation: '/mainNavigation',
      observers: [routeObserver],
      routes: [
        GoRoute(
          path: '/mainNavigation',
          builder: (context, state) => Scaffold(
            bottomNavigationBar: HomeBottomNavBar(
              currentIndex: 0,
              cartItemCount: 0,
              onTap: (_) {},
            ),
            body: ElevatedButton(
              onPressed: () => context.push('/product-detail'),
              child: const Text('Go Detail'),
            ),
          ),
        ),
        GoRoute(
          path: '/product-detail',
          builder: (context, state) => Scaffold(
            body: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Pop via Navigator'),
            ),
          ),
        ),
      ],
    );
    final cartBadgeController = CartBadgeController(_CartRepositoryStub());

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        builder: (context, child) => AppBottomNavigationShell(
          router: router,
          cartBadgeController: cartBadgeController,
          routeObserver: routeObserver,
          child: child!,
        ),
      ),
    );

    // Initially on /mainNavigation: exactly 1 HomeBottomNavBar (from Scaffold)
    expect(find.byType(HomeBottomNavBar), findsOneWidget);

    // Open product detail: product detail hides bottom navigation shell
    await tester.tap(find.text('Go Detail'));
    await tester.pumpAndSettle();

    expect(find.byType(HomeBottomNavBar), findsNothing);

    // Pop product detail via Navigator (like Android system back or iOS swipe)
    await tester.tap(find.text('Pop via Navigator'));
    await tester.pumpAndSettle();

    // After pop: back on /mainNavigation, exactly 1 HomeBottomNavBar (not duplicated!)
    expect(find.byType(HomeBottomNavBar), findsOneWidget);
  });

  testWidgets('does not duplicate bottom navigation after opening product detail and popping it via AppNavigation', (tester) async {
    final routeObserver = AppRouteObserver(initialRoute: '/mainNavigation');
    final router = GoRouter(
      initialLocation: '/mainNavigation',
      observers: [routeObserver],
      routes: [
        GoRoute(
          path: '/mainNavigation',
          builder: (context, state) => Scaffold(
            bottomNavigationBar: HomeBottomNavBar(
              currentIndex: 0,
              cartItemCount: 0,
              onTap: (_) {},
            ),
            body: ElevatedButton(
              onPressed: () => context.push('/product-detail'),
              child: const Text('Go Detail'),
            ),
          ),
        ),
        GoRoute(
          path: '/product-detail',
          builder: (context, state) => Scaffold(
            body: ElevatedButton(
              onPressed: () => AppNavigation.popOrGo(context),
              child: const Text('Pop via AppNavigation'),
            ),
          ),
        ),
      ],
    );
    final cartBadgeController = CartBadgeController(_CartRepositoryStub());

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        builder: (context, child) => AppBottomNavigationShell(
          router: router,
          cartBadgeController: cartBadgeController,
          routeObserver: routeObserver,
          child: child!,
        ),
      ),
    );

    expect(find.byType(HomeBottomNavBar), findsOneWidget);

    await tester.tap(find.text('Go Detail'));
    await tester.pumpAndSettle();

    expect(find.byType(HomeBottomNavBar), findsNothing);

    await tester.tap(find.text('Pop via AppNavigation'));
    await tester.pumpAndSettle();

    expect(find.byType(HomeBottomNavBar), findsOneWidget);
  });

  testWidgets('hides bottom navigation during splash, onboarding, auth, product-detail, and checkout', (
    tester,
  ) async {
    const hiddenLocations = [
      '/',
      '/onboarding',
      '/products',
      '/product-detail',
      '/checkout',
      '/order-details',
      '/notification-details',
      '/auth/login',
      '/auth/register',
      '/auth/forgot-password',
      '/auth/reset-password',
      '/auth/verification',
    ];
    final routeObserver = AppRouteObserver(initialRoute: '/');
    final router = GoRouter(
      initialLocation: '/',
      observers: [routeObserver],
      routes: [
        for (final path in hiddenLocations)
          GoRoute(
            path: path,
            builder: (context, state) => Scaffold(body: Text(path)),
          ),
      ],
    );
    final cartBadgeController = CartBadgeController(_CartRepositoryStub());

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => AppBottomNavigationShell(
          router: router,
          cartBadgeController: cartBadgeController,
          routeObserver: routeObserver,
          child: child!,
        ),
      ),
    );

    for (final path in hiddenLocations) {
      router.go(path);
      await tester.pumpAndSettle();

      expect(find.text(path), findsOneWidget);
      expect(find.text('Coupons'), findsNothing, reason: 'Route: $path');
      expect(find.text('Cart'), findsNothing, reason: 'Route: $path');
    }
  });
}

class _CartRepositoryStub implements CartRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
