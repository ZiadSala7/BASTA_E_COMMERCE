part of '../main_navigation_page.dart';

class _MainNavigationPageState extends State<MainNavigationPage>
    with WidgetsBindingObserver {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late final CartBadgeController _cartBadgeController;
  late final NotificationsController _notificationsController;
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _cartBadgeController = sl<CartBadgeController>();
    _notificationsController = sl<NotificationsController>();
    _cartBadgeController.refresh();
    _notificationsController.setupAfterLogin();

    _pages = [
      HomePage(
        onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      MyCouponsPage(
        onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
        isTab: true,
      ),
      OrdersPage(
        onBack: () {
          setState(() {
            _currentIndex = 0;
          });
        },
      ),
      CartPage(
        onBack: () {
          setState(() {
            _currentIndex = 0;
          });
        },
        onStartShopping: () {
          setState(() {
            _currentIndex = 0;
          });
        },
      ),
      AccountPage(
        onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
    ];
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _notificationsController.refreshUnreadCount();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: AnimatedBuilder(
        animation: _cartBadgeController,
        builder: (context, child) {
          return HomeBottomNavBar(
            currentIndex: _currentIndex,
            cartItemCount: _cartBadgeController.itemCount,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          );
        },
      ),
    );
  }
}
