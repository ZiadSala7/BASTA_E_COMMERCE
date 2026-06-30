part of '../cart_checkout_page.dart';

class _TotalsPanel extends StatelessWidget {
  final double subtotal;
  final double shipping;
  final double total;

  const _TotalsPanel({
    required this.subtotal,
    required this.shipping,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return _Panel(
      title: l10n.pick(ar: 'ملخص الدفع', en: 'Payment summary'),
      child: Column(
        children: [
          _TotalLine(label: l10n.subtotal, value: _money(subtotal)),
          const SizedBox(height: 8),
          _TotalLine(
            label: l10n.pick(ar: 'الشحن', en: 'Shipping'),
            value: _money(shipping),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1),
          ),
          _TotalLine(
            label: l10n.grandTotal,
            value: _money(total),
            isBold: true,
          ),
        ],
      ),
    );
  }
}
