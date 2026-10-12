part of '../cart_page.dart';

class _CartHeader extends StatelessWidget {
  const _CartHeader({
    required this.itemCount,
    required this.subtotal,
  });

  final int itemCount;
  final double subtotal;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final topPadding = MediaQuery.paddingOf(context).top;

    return Container(
      padding: EdgeInsets.fromLTRB(18, topPadding + 12, 18, 18),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primary],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(26)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.16),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.24)),
                ),
                child: const Icon(
                  Icons.shopping_bag_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.cart,
                      textAlign: TextAlign.start,
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      l10n.pick(
                        ar: '$itemCount عناصر في السلة',
                        en: '$itemCount items in your cart',
                      ),
                      textAlign: TextAlign.start,
                      style: GoogleFonts.cairo(
                        color: Colors.white.withOpacity(0.78),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _HeaderMetric(
                  label: l10n.pick(ar: 'المجموع الفرعي', en: 'Subtotal'),
                  value: _money(subtotal),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HeaderMetric(
                  label: l10n.pick(ar: 'حالة الطلب', en: 'Order status'),
                  value: l10n.pick(ar: 'جاهز', en: 'Ready'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
