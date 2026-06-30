import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/extensions/app_localizations_x.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/order_entity.dart';
import 'order_date_label.dart';

class OrderTotalSummary extends StatelessWidget {
  const OrderTotalSummary({required this.order, super.key});

  final OrderEntity order;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: _Amount(order: order)),
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
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  orderDateLabel(context, order.estimatedDeliveryAt),
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
    );
  }
}

class _Amount extends StatelessWidget {
  const _Amount({required this.order});

  final OrderEntity order;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.total,
          style: GoogleFonts.cairo(
            fontSize: 12,
            color: colors.onSurfaceVariant,
          ),
        ),
        Text(
          l10n.currencyAmount(order.total.toStringAsFixed(2)),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: colors.onSurface,
          ),
        ),
      ],
    );
  }
}
