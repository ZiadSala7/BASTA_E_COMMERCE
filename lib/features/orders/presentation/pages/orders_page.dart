import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/extensions/app_localizations_x.dart';
import '../../../../core/utils/app_router.dart';
import '../../../../core/widgets/common/custom_app_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/usecases/get_my_orders_usecase.dart';
import '../widgets/orders_list.dart';
import '../widgets/orders_status.dart';
import '../widgets/orders_tab_bar.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage>
    with SingleTickerProviderStateMixin {
  late final GetMyOrdersUseCase _getOrders = sl<GetMyOrdersUseCase>();
  late final TabController _tabs = TabController(length: 4, vsync: this);
  late Future<List<OrderEntity>> _orders = _getOrders();

  Future<void> _refresh() async {
    setState(() => _orders = _getOrders());
    await _orders;
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: CustomAppBar(
        title: l10n.myOrders,
        centerTitle: true,
        showSearch: false,
        leading: IconButton(
          onPressed: _handleBack,
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          OrdersTabBar(controller: _tabs),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: OrdersStatusFilter.values
                  .map(
                    (status) => OrdersList(
                      status: status,
                      ordersFuture: _orders,
                      onRefresh: _refresh,
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _handleBack() {
    if (widget.onBack case final onBack?) return onBack();
    if (context.canPop()) return context.pop();
    context.go(AppRoutes.mainNavigation);
  }
}
