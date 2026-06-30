import 'package:flutter/material.dart';

import '../../domain/entities/order_entity.dart';
import 'order_card_details.dart';
import 'order_card_header.dart';
import 'order_total_summary.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({required this.order, super.key});

  final OrderEntity order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: theme.brightness == Brightness.dark ? 0.24 : 0.05,
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
            OrderCardHeader(order: order),
            const SizedBox(height: 12),
            OrderCardDetails(order: order),
            const SizedBox(height: 12),
            OrderTotalSummary(order: order),
          ],
        ),
      ),
    );
  }
}
