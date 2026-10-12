import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/cart/domain/services/cart_badge_controller.dart';
import '../../features/home/presentation/widgets/home_bottom_nav_bar.dart';
import '../utils/app_router.dart';

class AppBottomNavigationShell extends StatelessWidget {
  const AppBottomNavigationShell({
    required this.router,
    required this.cartBadgeController,
    required this.child,
    super.key,
  });

  final GoRouter router;
  final CartBadgeController cartBadgeController;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<RouteInformation>(
      valueListenable: router.routeInformationProvider,
      builder: (context, routeInformation, _) {
        final location = routeInformation.uri.path;
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

  bool _shouldShowNavigationBar(String location) {
    if (location == AppRoutes.mainNavigation ||
        location == AppRoutes.splash ||
        location == AppRoutes.onboarding ||
        location.startsWith('/auth/')) {
      return false;
    }

    return true;
  }

  int _selectedIndex(String location) {
    if (location == AppRoutes.coupons) return 1;
    if (location == AppRoutes.orders || location == AppRoutes.orderDetails) {
      return 2;
    }
    if (location == AppRoutes.cart || location == AppRoutes.checkout) {
      return 3;
    }
    if (location == AppRoutes.account ||
        location == AppRoutes.addresses ||
        location == AppRoutes.inviteFriends ||
        location == AppRoutes.privacyPolicy ||
        location == AppRoutes.aboutUs ||
        location == AppRoutes.faq ||
        location == AppRoutes.contactUs) {
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
