import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/extensions/app_localizations_x.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_router.dart';
import '../../../../core/utils/currency_helper.dart';
import '../../../../core/widgets/common/custom_app_bar.dart';
import '../../../../core/widgets/status/empty_state.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/orders_repository.dart';
import '../widgets/orders_status.dart';

class OrderDetailsPage extends StatefulWidget {
  final String orderId;
  final OrderEntity? initialOrder;

  const OrderDetailsPage({
    super.key,
    required this.orderId,
    this.initialOrder,
  });

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  late final OrdersRepository _ordersRepository;
  OrderEntity? _order;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _ordersRepository = sl<OrdersRepository>();
    _order = widget.initialOrder;
    _fetchOrderDetails();
  }

  Future<void> _fetchOrderDetails() async {
    if (_order != null && _order!.items.isNotEmpty && _order!.shippingAddress != null) {
      setState(() => _isLoading = false);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final fetched = await _ordersRepository.getOrderById(widget.orderId);
      if (!mounted) return;
      setState(() {
        _order = fetched ?? _order;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final order = _order;

    return Directionality(
      textDirection: l10n.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: CustomAppBar(
          title: l10n.pick(ar: 'تفاصيل الطلب', en: 'Order Details'),
          centerTitle: true,
          showSearch: false,
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          ),
        ),
        body: _isLoading && order == null
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null && order == null
            ? EmptyState(
                icon: Icons.error_outline_rounded,
                title: l10n.pick(ar: 'تعذر تحميل تفاصيل الطلب', en: 'Failed to load order details'),
                message: _errorMessage,
                actionLabel: l10n.tryAgain,
                onActionTap: _fetchOrderDetails,
              )
            : RefreshIndicator(
                onRefresh: _fetchOrderDetails,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 40),
                  children: [
                    if (order != null) ...[
                      // ── 1. Hero Order ID & Status Header Card ──────────
                      _buildHeaderCard(context, order, l10n),

                      const SizedBox(height: 16),

                      // ── 2. Order Tracking Timeline Stepper ─────────────
                      _buildTrackingStepper(context, order, l10n),

                      const SizedBox(height: 16),

                      // ── 3. Ordered Products & Items Card ───────────────
                      _buildItemsCard(context, order, l10n),

                      const SizedBox(height: 16),

                      // ── 4. Delivery & Shipping Address Card ────────────
                      _buildShippingAddressCard(context, order, l10n),

                      const SizedBox(height: 16),

                      // ── 5. Payment Details Card ────────────────────────
                      _buildPaymentInfoCard(context, order, l10n),

                      const SizedBox(height: 16),

                      // ── 6. Price Breakdown & Totals Card ───────────────
                      _buildPriceSummaryCard(context, order, l10n),

                      const SizedBox(height: 24),

                      // ── 7. Action Buttons ──────────────────────────────
                      _buildActionButtons(context, order, l10n),
                    ],
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, OrderEntity order, AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = orderStatusColor(order.status);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.pick(ar: 'رقم الطلب', en: 'Order Number'),
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            '#${order.id}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.cairo(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w900,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        InkWell(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: order.id));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  l10n.pick(ar: 'تم نسخ رقم الطلب', en: 'Order ID copied'),
                                  style: GoogleFonts.cairo(),
                                ),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(Icons.copy_rounded, size: 16, color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: statusColor.withValues(alpha: 0.28)),
                ),
                child: Text(
                  orderStatusLabel(l10n, order.status),
                  style: GoogleFonts.cairo(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          if (order.createdAt != null) ...[
            const SizedBox(height: 12),
            Divider(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 14, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 6),
                Text(
                  _formatDate(order.createdAt!),
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTrackingStepper(BuildContext context, OrderEntity order, AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    final status = order.status.toUpperCase();
    final isCancelled = status == 'CANCELLED' || status == 'FAILED';

    final steps = [
      {'title': l10n.pick(ar: 'تم الطلب', en: 'Placed'), 'key': 'PLACED', 'icon': Icons.receipt_long_rounded},
      {'title': l10n.pick(ar: 'قيد التجهيز', en: 'Processing'), 'key': 'PROCESSING', 'icon': Icons.inventory_2_outlined},
      {'title': l10n.pick(ar: 'قيد الشحن', en: 'Shipped'), 'key': 'SHIPPED', 'icon': Icons.local_shipping_outlined},
      {'title': l10n.pick(ar: 'تم التسليم', en: 'Delivered'), 'key': 'DELIVERED', 'icon': Icons.task_alt_rounded},
    ];

    int currentStepIndex = 0;
    if (status == 'CONFIRMED' || status == 'PROCESSING') {
      currentStepIndex = 1;
    } else if (status == 'SHIPPED' || status == 'OUT_FOR_DELIVERY') {
      currentStepIndex = 2;
    } else if (status == 'DELIVERED' || status == 'COMPLETED') {
      currentStepIndex = 3;
    }

    if (isCancelled) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            const Icon(Icons.cancel_outlined, color: Colors.red, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.pick(ar: 'تم إلغاء هذا الطلب', en: 'This order was cancelled'),
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.red.shade700,
                    ),
                  ),
                  Text(
                    l10n.pick(ar: 'تم تحرير المنتجات واسترجاع المخزون بنجاح.', en: 'Items were released and inventory restored.'),
                    style: GoogleFonts.cairo(
                      fontSize: 11.5,
                      color: Colors.red.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.pick(ar: 'تتبع مسار الطلب', en: 'Order Tracking Timeline'),
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(steps.length, (index) {
              final step = steps[index];
              final isDone = index <= currentStepIndex;
              final isCurrent = index == currentStepIndex;
              final stepColor = isDone ? AppColors.primary : colorScheme.outlineVariant;

              return Expanded(
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        if (index < steps.length - 1)
                          Positioned(
                            left: l10n.isArabic ? -30 : 30,
                            right: l10n.isArabic ? 30 : -30,
                            child: Container(
                              height: 3,
                              color: index < currentStepIndex
                                  ? AppColors.primary
                                  : colorScheme.outlineVariant.withValues(alpha: 0.5),
                            ),
                          ),
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: isDone ? AppColors.primary : colorScheme.surface,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isCurrent ? AppColors.primary : stepColor,
                              width: isCurrent ? 2.5 : 1.5,
                            ),
                            boxShadow: isCurrent
                                ? [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Icon(
                            step['icon'] as IconData,
                            size: 18,
                            color: isDone ? Colors.white : colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      step['title'] as String,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                        color: isCurrent ? AppColors.primary : colorScheme.onSurfaceVariant,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsCard(BuildContext context, OrderEntity order, AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    final items = order.items;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shopping_bag_outlined, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                items.isNotEmpty
                    ? l10n.pick(
                        ar: 'المنتجات في هذا الطلب (${items.length})',
                        en: 'Items in this Order (${items.length})',
                      )
                    : l10n.pick(
                        ar: 'المنتجات في هذا الطلب',
                        en: 'Items in this Order',
                      ),
                style: GoogleFonts.cairo(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.pick(
                      ar: 'جاري تحميل تفاصيل المنتجات...',
                      en: 'Loading product details...',
                    ),
                    style: GoogleFonts.cairo(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, __) => Divider(
                color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                height: 24,
              ),
              itemBuilder: (context, index) {
                final item = items[index];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Thumbnail
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                            ? Image.network(
                                item.imageUrl!.startsWith('http')
                                    ? item.imageUrl!
                                    : 'https://api.bs6a.com${item.imageUrl}',
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(Icons.inventory_2_outlined, color: Colors.grey),
                              )
                            : const Icon(Icons.shopping_bag_outlined, color: Colors.grey),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.productName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.cairo(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: colorScheme.onSurface,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (item.storeName != null && item.storeName!.isNotEmpty) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '🏪 ${item.storeName}',
                                style: GoogleFonts.cairo(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                          ],
                          if (item.trackingNumber != null && item.trackingNumber!.isNotEmpty)
                            Text(
                              '${l10n.pick(ar: 'رقم التتبع', en: 'Tracking')}: #${item.trackingNumber}',
                              style: GoogleFonts.cairo(
                                fontSize: 11,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          CurrencyHelper.format(item.totalPrice),
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          'x${item.quantity}',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildShippingAddressCard(BuildContext context, OrderEntity order, AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    final address = order.shippingAddress;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                l10n.pick(ar: 'عنوان التوصيل والشحن', en: 'Delivery & Shipping Address'),
                style: GoogleFonts.cairo(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            address != null && address.fullAddress.isNotEmpty
                ? address.fullAddress
                : l10n.pick(ar: 'موقع التوصيل المحدد على الخريطة', en: 'Pinned delivery location'),
            style: GoogleFonts.cairo(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
              height: 1.4,
            ),
          ),
          if (address?.phone != null && address!.phone!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.phone_outlined, size: 14, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 6),
                Text(
                  address.phone!,
                  style: GoogleFonts.cairo(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentInfoCard(BuildContext context, OrderEntity order, AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    final isCard = order.paymentMethod.toUpperCase() == 'CARD';
    final isPaid = order.paymentStatus.toUpperCase() == 'PAID';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.payment_rounded, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                l10n.pick(ar: 'معلومات الدفع', en: 'Payment Information'),
                style: GoogleFonts.cairo(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildRow(
            label: l10n.pick(ar: 'طريقة الدفع', en: 'Payment Method'),
            value: isCard
                ? l10n.pick(ar: '💳 بطاقة بنكية (Mastercard/Visa)', en: '💳 Credit / Debit Card')
                : l10n.pick(ar: '💵 الدفع عند الاستلام (COD)', en: '💵 Cash On Delivery (COD)'),
            context: context,
          ),
          const Divider(height: 18),
          _buildRow(
            label: l10n.pick(ar: 'حالة الدفع', en: 'Payment Status'),
            value: isPaid
                ? l10n.pick(ar: '🟢 مدفوع بالكامل', en: '🟢 Paid')
                : order.paymentStatus.toUpperCase() == 'FAILED'
                ? l10n.pick(ar: '🔴 غير مكتمل / ملغي', en: '🔴 Failed / Cancelled')
                : l10n.pick(ar: '🟡 قيد الانتظار', en: '🟡 Pending'),
            context: context,
            valueColor: isPaid
                ? AppColors.accentGreen
                : order.paymentStatus.toUpperCase() == 'FAILED'
                ? AppColors.badgeRed
                : const Color(0xFFF59E0B),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSummaryCard(BuildContext context, OrderEntity order, AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_outlined, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                l10n.pick(ar: 'ملخص الحساب والفاتورة', en: 'Payment Summary'),
                style: GoogleFonts.cairo(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildRow(
            label: l10n.pick(ar: 'مجموع المنتجات', en: 'Subtotal'),
            value: CurrencyHelper.format(order.subtotal),
            context: context,
          ),
          const SizedBox(height: 8),
          _buildRow(
            label: l10n.pick(ar: 'رسوم الشحن والتوصيل', en: 'Shipping Fee'),
            value: CurrencyHelper.format(order.shippingCost),
            context: context,
          ),
          if (order.discountAmount > 0) ...[
            const SizedBox(height: 8),
            _buildRow(
              label: l10n.pick(ar: 'الخصم وقسيمة الشراء', en: 'Discount'),
              value: '- ${CurrencyHelper.format(order.discountAmount)}',
              context: context,
              valueColor: AppColors.accentGreen,
            ),
          ],
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.pick(ar: 'المبلغ الإجمالي الكلي', en: 'Grand Total'),
                style: GoogleFonts.cairo(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                CurrencyHelper.format(order.total),
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRow({
    required String label,
    required String value,
    required BuildContext context,
    Color? valueColor,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.cairo(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: valueColor ?? colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, OrderEntity order, AppLocalizations l10n) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: () async {
            try {
              final invoiceUrl = await _ordersRepository.getOrderInvoiceUrl(order.id);
              if (!mounted) return;
              if (invoiceUrl != null && invoiceUrl.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      l10n.pick(ar: 'رابط الفاتورة: $invoiceUrl', en: 'Invoice URL: $invoiceUrl'),
                      style: GoogleFonts.cairo(),
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      l10n.pick(ar: 'الفاتورة الإلكترونية قيد المعالجة', en: 'Invoice is processing'),
                      style: GoogleFonts.cairo(),
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            } catch (_) {}
          },
          icon: const Icon(Icons.download_rounded, size: 18),
          label: Text(l10n.pick(ar: 'تحميل الفاتورة الإلكترونية', en: 'Download Invoice')),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            textStyle: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () => context.push(AppRoutes.products),
          icon: const Icon(Icons.shopping_bag_outlined, size: 18),
          label: Text(l10n.pick(ar: 'تصفح المزيد من المنتجات', en: 'Continue Shopping')),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            minimumSize: const Size.fromHeight(50),
            side: const BorderSide(color: AppColors.primary),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            textStyle: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    final hour = local.hour > 12 ? local.hour - 12 : (local.hour == 0 ? 12 : local.hour);
    final period = local.hour >= 12 ? 'م' : 'ص';
    final minute = local.minute.toString().padLeft(2, '0');
    return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}  $hour:$minute $period';
  }
}
