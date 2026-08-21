part of '../enhanced_checkout_page.dart';

class _OrderTotals extends StatelessWidget {
  const _OrderTotals();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        _TotalRow(
          label: l10n.pick(ar: 'المجموع الفرعي', en: 'Subtotal'),
          value: l10n.formatPrice(189.98),
        ),
        const SizedBox(height: 6),
        _TotalRow(
          label: l10n.pick(ar: 'التوصيل', en: 'Shipping'),
          value: l10n.formatPrice(5.00),
        ),
        const SizedBox(height: 6),
        _TotalRow(
          label: l10n.pick(ar: 'الضريبة', en: 'Tax'),
          value: l10n.formatPrice(15.00),
        ),
        const SizedBox(height: 12),
        const Divider(height: 1),
        const SizedBox(height: 8),
        _TotalRow(
          label: l10n.pick(ar: 'المجموع الكلي', en: 'Total'),
          value: l10n.formatPrice(209.98),
          isBold: true,
          isHighlighted: true,
        ),
      ],
    );
  }
}
