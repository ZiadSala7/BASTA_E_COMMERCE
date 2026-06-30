import 'package:flutter/material.dart';

import '../../../../core/extensions/app_localizations_x.dart';
import '../../../../core/widgets/status/empty_state.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/order_entity.dart';
import 'order_card.dart';
import 'order_payment_state.dart';
import 'orders_status.dart';
import 'refreshable_order_state.dart';

class OrdersList extends StatelessWidget {
  const OrdersList({
    required this.status,
    required this.ordersFuture,
    required this.onRefresh,
    super.key,
  });

  final OrdersStatusFilter status;
  final Future<List<OrderEntity>> ordersFuture;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<OrderEntity>>(
      future: ordersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) return _error(context, snapshot.error);
        final orders = _filtered(snapshot.data ?? const []);
        if (orders.isEmpty) return _empty(context);
        return RefreshIndicator(
          onRefresh: onRefresh,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (_, index) => OrderCard(order: orders[index]),
          ),
        );
      },
    );
  }

  Widget _error(BuildContext context, Object? error) {
    final l10n = AppLocalizations.of(context)!;
    return RefreshableOrderState(
      onRefresh: onRefresh,
      child: EmptyState(
        icon: Icons.receipt_long_outlined,
        title: l10n.pick(ar: 'تعذر تحميل الطلبات', en: 'Could not load orders'),
        message: '${error ?? ''}'.replaceFirst(RegExp(r'^Exception:\s*'), ''),
        actionLabel: l10n.pick(ar: 'إعادة المحاولة', en: 'Try again'),
        onActionTap: onRefresh,
      ),
    );
  }

  Widget _empty(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return RefreshableOrderState(
      onRefresh: onRefresh,
      child: EmptyState(
        icon: Icons.shopping_bag_outlined,
        title: l10n.pick(ar: 'لا توجد طلبات', en: 'No orders yet'),
        message: l10n.pick(
          ar: 'ستظهر طلباتك هنا بعد إتمام أول عملية شراء.',
          en: 'Your orders will appear here after your first purchase.',
        ),
      ),
    );
  }

  List<OrderEntity> _filtered(List<OrderEntity> orders) {
    final visible = orders.where((order) => !order.isUnpaidCardOrder);
    if (status == OrdersStatusFilter.all) return visible.toList();
    return visible
        .where((order) => orderStatusFilter(order.status) == status)
        .toList();
  }
}
