import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/extensions/app_localizations_x.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/order_entity.dart';
import 'orders_status.dart';

class OrderCardHeader extends StatelessWidget {
  const OrderCardHeader({required this.order, super.key});

  final OrderEntity order;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final statusColor = orderStatusColor(order.status);
    final shortId = order.id.isNotEmpty
        ? order.id.substring(0, min(8, order.id.length)).toUpperCase()
        : '';

    final isCard = order.paymentMethod.toUpperCase() == 'CARD';
    final isPaid = order.paymentStatus.toUpperCase() == 'PAID';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
              ),
              child: Text(
                '#$shortId',
                style: GoogleFonts.cairo(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isCard
                    ? (isPaid
                        ? AppColors.accentGreen.withValues(alpha: 0.1)
                        : const Color(0xFFF59E0B).withValues(alpha: 0.1))
                    : Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isCard ? Icons.credit_card_rounded : Icons.local_atm_rounded,
                    size: 13,
                    color: isCard
                        ? (isPaid ? AppColors.accentGreen : const Color(0xFFD97706))
                        : Colors.amber.shade800,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isCard
                        ? (isPaid
                            ? l10n.pick(ar: 'مدفوع', en: 'Paid')
                            : l10n.pick(ar: 'بطاقة', en: 'Card'))
                        : l10n.pick(ar: 'عند الاستلام', en: 'COD'),
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: isCard
                          ? (isPaid ? AppColors.accentGreen : const Color(0xFFD97706))
                          : Colors.amber.shade800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: statusColor.withValues(alpha: 0.28)),
          ),
          child: Text(
            orderStatusLabel(l10n, order.status),
            style: GoogleFonts.cairo(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: statusColor,
            ),
          ),
        ),
      ],
    );
  }
}
