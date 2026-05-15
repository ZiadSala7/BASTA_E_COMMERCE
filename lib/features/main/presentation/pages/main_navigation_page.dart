import 'package:flutter/material.dart';
import '../../../offers/presentation/pages/offers_page.dart';
import '../../../cart/presentation/pages/cart_page.dart';
import '../../../orders/presentation/pages/orders_page.dart';
import '../../../account/presentation/pages/account_page.dart';
import '../../../home/presentation/widgets/home_bottom_nav_bar.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../../core/widgets/app_drawer.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomePage(onMenuPressed: () => _scaffoldKey.currentState?.openDrawer()),
      OffersPage(onMenuPressed: () => _scaffoldKey.currentState?.openDrawer()),
      const OrdersPage(),
      CartPage(
        onStartShopping: () {
          setState(() {
            _currentIndex = 0;
          });
        },
      ),
      AccountPage(onMenuPressed: () => _scaffoldKey.currentState?.openDrawer()),
    ];

    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: HomeBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
