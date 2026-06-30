part of '../cart_page.dart';

class _OrderReadinessPanel extends StatelessWidget {
  const _OrderReadinessPanel({required this.itemCount, required this.subtotal});

  final int itemCount;
  final double subtotal;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 170,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: colorScheme.outlineVariant.withOpacity(0.7),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF8F5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.verified_user_outlined,
                    color: Color(0xFF129987),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.pick(
                          ar: 'طلبك جاهز للمراجعة',
                          en: 'Your order is ready',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cairo(
                          color: colorScheme.onSurface,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        l10n.pick(
                          ar: 'تحقق من المنتجات والكوبون قبل الدفع.',
                          en: 'Review items and coupon before checkout.',
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cairo(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _ReadinessChip(
                    icon: Icons.inventory_2_outlined,
                    label: l10n.pick(ar: 'العناصر', en: 'Items'),
                    value: '$itemCount',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ReadinessChip(
                    icon: Icons.local_shipping_outlined,
                    label: l10n.pick(ar: 'الشحن', en: 'Shipping'),
                    value: '2-4d',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ReadinessChip(
                    icon: Icons.payments_outlined,
                    label: l10n.pick(ar: 'المجموع', en: 'Subtotal'),
                    value: _money(subtotal),
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
