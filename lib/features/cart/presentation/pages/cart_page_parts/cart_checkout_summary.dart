part of '../cart_page.dart';

class _CartCheckoutSummary extends StatelessWidget {
  const _CartCheckoutSummary({
    required this.subtotal,
    required this.shipping,
    required this.discount,
    required this.onCheckout,
  });

  final double subtotal;
  final double shipping;
  final double discount;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final total = subtotal + shipping - discount;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 28,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 12),
            _SummaryRow(
              label: l10n.pick(ar: 'المجموع الفرعي', en: 'Subtotal'),
              value: _money(subtotal),
            ),
            const SizedBox(height: 6),
            _SummaryRow(
              label: l10n.pick(ar: 'الشحن', en: 'Shipping'),
              value: _money(shipping),
            ),
            if (discount > 0) ...[
              const SizedBox(height: 6),
              _SummaryRow(
                label: l10n.pick(ar: 'خصم الكوبون', en: 'Coupon discount'),
                value: '-${_money(discount)}',
                valueColor: AppColors.accentGreen,
              ),
            ],
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.pick(ar: 'الإجمالي', en: 'Total'),
                        style: GoogleFonts.cairo(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _money(total),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cairo(
                          color: AppColors.primary,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: onCheckout,
                    icon: const Icon(Icons.lock_outline_rounded, size: 18),
                    label: Text(
                      l10n.proceedToCheckout,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
