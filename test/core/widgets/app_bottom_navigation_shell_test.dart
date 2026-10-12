import 'package:busta/core/widgets/app_bottom_navigation_shell.dart';
import 'package:busta/features/cart/domain/repositories/cart_repository.dart';
import 'package:busta/features/cart/domain/services/cart_badge_controller.dart';
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

  testWidgets('hides bottom navigation during splash, onboarding, and auth', (
    tester,
  ) async {
    const preShoppingLocations = [
      '/',
      '/onboarding',
      '/auth/login',
      '/auth/register',
      '/auth/forgot-password',
      '/auth/reset-password',
      '/auth/verification',
    ];
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        for (final path in preShoppingLocations)
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
          child: child!,
        ),
      ),
    );

    for (final path in preShoppingLocations) {
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
