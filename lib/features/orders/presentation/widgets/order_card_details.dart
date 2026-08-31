import 'package:flutter/material.dart';

import '../../../../core/extensions/app_localizations_x.dart';
import '../../../../core/utils/currency_helper.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/order_entity.dart';
import 'order_date_label.dart';
import 'order_meta.dart';

class OrderCardDetails extends StatelessWidget {
  const OrderCardDetails({required this.order, super.key});

  final OrderEntity order;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        OrderMeta(
          icon: Icons.calendar_today_outlined,
          label: orderDateLabel(context, order.createdAt),
        ),
        if (order.itemsCount > 0)
          OrderMeta(
            icon: Icons.shopping_bag_outlined,
            label: l10n.itemCount(order.itemsCount),
          ),
        if (order.shippingCost > 0)
          OrderMeta(
            icon: Icons.local_shipping_outlined,
            label: '${l10n.pick(ar: 'الشحن', en: 'Shipping')}: ${CurrencyHelper.format(order.shippingCost)}',
          ),
      ],
    );
  }
}
