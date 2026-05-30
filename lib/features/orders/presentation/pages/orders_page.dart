// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/extensions/app_localizations_x.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/widgets/common/custom_app_bar.dart';
import '../../../../core/widgets/status/empty_state.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/usecases/get_my_orders_usecase.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage>
    with SingleTickerProviderStateMixin {
  late final GetMyOrdersUseCase _getMyOrders;
  late final TabController _tabController;
  late Future<List<OrderEntity>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _getMyOrders = sl<GetMyOrdersUseCase>();
    _ordersFuture = _getMyOrders();
    _tabController = TabController(length: 4, vsync: this);
  }

  Future<void> _refreshOrders() async {
    setState(() {
      _ordersFuture = _getMyOrders();
    });
    await _ordersFuture;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: l10n.myOrders,
        centerTitle: true,
        showSearch: false,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: colorScheme.surface,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: AppColors.primary,
              indicatorWeight: 2,
              labelColor: AppColors.primary,
              unselectedLabelColor: colorScheme.onSurfaceVariant,
              labelStyle: GoogleFonts.cairo(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              unselectedLabelStyle: GoogleFonts.cairo(
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
              tabs: [
                Tab(text: l10n.all),
                Tab(text: l10n.pending),
                Tab(text: l10n.delivering),
                Tab(text: l10n.delivered),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _OrdersList(
                  status: _OrderStatusFilter.all,
                  ordersFuture: _ordersFuture,
                  onRefresh: _refreshOrders,
                ),
                _OrdersList(
                  status: _OrderStatusFilter.pending,
                  ordersFuture: _ordersFuture,
                  onRefresh: _refreshOrders,
                ),
                _OrdersList(
                  status: _OrderStatusFilter.delivering,
                  ordersFuture: _ordersFuture,
                  onRefresh: _refreshOrders,
                ),
                _OrdersList(
                  status: _OrderStatusFilter.delivered,
                  ordersFuture: _ordersFuture,
                  onRefresh: _refreshOrders,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _OrderStatusFilter { all, pending, delivering, delivered }

class _OrdersList extends StatelessWidget {
  final _OrderStatusFilter status;
  final Future<List<OrderEntity>> ordersFuture;
  final Future<void> Function() onRefresh;

  const _OrdersList({
    required this.status,
    required this.ordersFuture,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return FutureBuilder<List<OrderEntity>>(
      future: ordersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _RefreshableState(
            onRefresh: onRefresh,
            child: EmptyState(
              icon: Icons.receipt_long_outlined,
              title: l10n.pick(
                ar: 'تعذر تحميل الطلبات',
                en: 'Could not load orders',
              ),
              message: _cleanError(snapshot.error),
              actionLabel: l10n.pick(ar: 'إعادة المحاولة', en: 'Try again'),
              onActionTap: onRefresh,
            ),
          );
        }

        final orders = _filterOrders(snapshot.data ?? const <OrderEntity>[]);
        if (orders.isEmpty) {
          return _RefreshableState(
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

        return RefreshIndicator(
          onRefresh: onRefresh,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) => _OrderCard(order: orders[index]),
          ),
        );
      },
    );
  }

  List<OrderEntity> _filterOrders(List<OrderEntity> orders) {
    if (status == _OrderStatusFilter.all) return orders;

    return orders
        .where((order) => _statusFilterFor(order.status) == status)
        .toList();
  }

  String _cleanError(Object? error) {
    final message = error?.toString() ?? '';
    return message.replaceFirst(RegExp(r'^Exception:\s*'), '');
  }
}

class _RefreshableState extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;

  const _RefreshableState({required this.child, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.55,
            child: child,
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderEntity order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final statusColor = _statusColor(order.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              theme.brightness == Brightness.dark ? 0.24 : 0.05,
            ),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${l10n.orderLabel}${order.id}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _statusLabel(l10n, order.status),
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _OrderMeta(
                  icon: Icons.shopping_bag_outlined,
                  label: l10n.itemCount(order.itemsCount),
                ),
                _OrderMeta(
                  icon: Icons.calendar_today_outlined,
                  label: _dateLabel(context, order.createdAt),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.total,
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        l10n.currencyAmount(order.total.toStringAsFixed(2)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                if (order.estimatedDeliveryAt != null) ...[
                  const SizedBox(width: 12),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          l10n.estimatedDelivery,
                          textAlign: TextAlign.end,
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          _dateLabel(context, order.estimatedDeliveryAt),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _dateLabel(BuildContext context, DateTime? date) {
    if (date == null) return '-';
    final l10n = AppLocalizations.of(context)!;
    return DateFormat.yMMMd(l10n.localeName).format(date.toLocal());
  }
}

class _OrderMeta extends StatelessWidget {
  final IconData icon;
  final String label;

  const _OrderMeta({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 13,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

_OrderStatusFilter _statusFilterFor(String status) {
  final normalized = _normalizeStatus(status);

  if (normalized.contains('delivered') ||
      normalized.contains('completed') ||
      normalized.contains('complete')) {
    return _OrderStatusFilter.delivered;
  }

  if (normalized.contains('deliver') ||
      normalized.contains('shipping') ||
      normalized.contains('shipped') ||
      normalized.contains('outfordelivery') ||
      normalized.contains('processing') ||
      normalized.contains('confirmed')) {
    return _OrderStatusFilter.delivering;
  }

  return _OrderStatusFilter.pending;
}

String _statusLabel(AppLocalizations l10n, String status) {
  switch (_statusFilterFor(status)) {
    case _OrderStatusFilter.delivered:
      return l10n.delivered;
    case _OrderStatusFilter.delivering:
      return l10n.delivering;
    case _OrderStatusFilter.pending:
      return l10n.pending;
    case _OrderStatusFilter.all:
      return status.isEmpty ? l10n.pending : status;
  }
}

Color _statusColor(String status) {
  switch (_statusFilterFor(status)) {
    case _OrderStatusFilter.delivered:
      return AppColors.primary;
    case _OrderStatusFilter.delivering:
      return Colors.orange;
    case _OrderStatusFilter.pending:
      return Colors.blue;
    case _OrderStatusFilter.all:
      return Colors.blueGrey;
  }
}

String _normalizeStatus(String status) {
  return status.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
}
