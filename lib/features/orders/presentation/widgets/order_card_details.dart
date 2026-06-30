import 'package:flutter/material.dart';

import '../../../../core/extensions/app_localizations_x.dart';
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
          icon: Icons.shopping_bag_outlined,
          label: l10n.itemCount(order.itemsCount),
        ),
        OrderMeta(
          icon: Icons.calendar_today_outlined,
          label: orderDateLabel(context, order.createdAt),
        ),
      ],
    );
  }
}
