import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/cart/domain/services/cart_badge_controller.dart';
import '../../features/home/presentation/widgets/home_bottom_nav_bar.dart';
import '../utils/app_route_observer.dart';
import '../utils/app_router.dart';

class AppBottomNavigationShell extends StatelessWidget {
  const AppBottomNavigationShell({
    required this.router,
    required this.cartBadgeController,
    required this.child,
    this.routeObserver,
    super.key,
  });

  final GoRouter router;
  final CartBadgeController cartBadgeController;
  final Widget child;
  final AppRouteObserver? routeObserver;

  @override
  Widget build(BuildContext context) {
    final listenable = routeObserver != null
        ? Listenable.merge([
            router.routeInformationProvider,
            routeObserver!.currentRoute,
          ])
        : router.routeInformationProvider;

    return ListenableBuilder(
      listenable: listenable,
      builder: (context, _) {
        final location = _resolveLocation();
        final showNavigationBar = _shouldShowNavigationBar(location);

        return ColoredBox(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: SizedBox.expand(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: child),
                if (showNavigationBar)
                  AnimatedBuilder(
                    animation: cartBadgeController,
                    builder: (context, _) => HomeBottomNavBar(
                      currentIndex: _selectedIndex(location),
                      cartItemCount: cartBadgeController.itemCount,
                      onTap: _navigateToTab,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _resolveLocation() {
    if (routeObserver != null && routeObserver!.currentRoute.value.isNotEmpty) {
      return routeObserver!.currentRoute.value;
    }
    return router.routeInformationProvider.value.uri.path;
  }

  bool _shouldShowNavigationBar(String location) {
    final normalized = Uri.tryParse(location)?.path ?? location;
    if (normalized == AppRoutes.mainNavigation ||
        normalized == AppRoutes.splash ||
        normalized == AppRoutes.onboarding ||
        normalized == AppRoutes.checkout ||
        normalized.startsWith('/auth/')) {
      return false;
    }

    return true;
  }

  int _selectedIndex(String location) {
    final normalized = Uri.tryParse(location)?.path ?? location;
    if (normalized == AppRoutes.coupons) return 1;
    if (normalized == AppRoutes.orders ||
        normalized == AppRoutes.orderDetails) {
      return 2;
    }
    if (normalized == AppRoutes.cart || normalized == AppRoutes.checkout) {
      return 3;
    }
    if (normalized == AppRoutes.account ||
        normalized == AppRoutes.addresses ||
        normalized == AppRoutes.inviteFriends ||
        normalized == AppRoutes.privacyPolicy ||
        normalized == AppRoutes.aboutUs ||
        normalized == AppRoutes.faq ||
        normalized == AppRoutes.contactUs) {
      return 4;
    }
    return 0;
  }

  void _navigateToTab(int index) {
    final location = switch (index) {
      0 => AppRoutes.mainNavigation,
      1 => AppRoutes.coupons,
      2 => AppRoutes.orders,
      3 => AppRoutes.cart,
      4 => AppRoutes.account,
      _ => throw RangeError.index(index, const [0, 1, 2, 3, 4]),
    };
    router.go(location);
  }
}
