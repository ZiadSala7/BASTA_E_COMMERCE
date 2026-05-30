import 'package:flutter/material.dart';
import '../../../offers/presentation/pages/offers_page.dart';
import '../../../cart/presentation/pages/cart_page.dart';
import '../../../orders/presentation/pages/orders_page.dart';
import '../../../account/presentation/pages/account_page.dart';
import '../../../home/presentation/widgets/home_bottom_nav_bar.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/di/service_locator.dart';
import '../../../cart/domain/services/cart_badge_controller.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late final CartBadgeController _cartBadgeController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _cartBadgeController = sl<CartBadgeController>();
    _cartBadgeController.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      body: _buildCurrentScreen(),
      bottomNavigationBar: AnimatedBuilder(
        animation: _cartBadgeController,
        builder: (context, child) {
          return HomeBottomNavBar(
            currentIndex: _currentIndex,
            cartItemCount: _cartBadgeController.itemCount,
            onTap: (index) {
              if (index == 3) _cartBadgeController.refresh();
              setState(() {
                _currentIndex = index;
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return HomePage(
          onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
        );
      case 1:
        return OffersPage(
          onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
        );
      case 2:
        return const OrdersPage();
      case 3:
        return CartPage(
          onStartShopping: () {
            setState(() {
              _currentIndex = 0;
            });
          },
        );
      case 4:
        return AccountPage(
          onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
        );
      default:
        return HomePage(
          onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
        );
    }
  }
}
