part of '../cart_checkout_page.dart';

class _CheckoutStatusCard extends StatelessWidget {
  final int itemCount;
  final int storeCount;

  const _CheckoutStatusCard({
    required this.itemCount,
    required this.storeCount,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final subtitle = storeCount > 0
        ? l10n.pick(
            ar: '$itemCount منتجات من $storeCount متاجر',
            en: '$itemCount products from $storeCount stores',
          )
        : l10n.pick(ar: '$itemCount منتجات', en: '$itemCount products');
    final title = storeCount > 1
        ? l10n.pick(ar: 'طلب متعدد المتاجر', en: 'Multi-vendor order')
        : l10n.pick(ar: 'مراجعة الطلب', en: 'Order review');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.cairo(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
