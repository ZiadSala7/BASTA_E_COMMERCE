part of '../cart_checkout_page.dart';

class _PaymentMethodsPanel extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _PaymentMethodsPanel({
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final methods = [
      _PaymentMethod(
        icon: Icons.payments_outlined,
        title: l10n.pick(ar: 'الدفع عند الاستلام', en: 'Cash on delivery'),
        subtitle: l10n.pick(
          ar: 'ادفع عند استلام الطلب',
          en: 'Pay when the order arrives',
        ),
      ),
      _PaymentMethod(
        icon: Icons.credit_card_rounded,
        title: l10n.pick(ar: 'بطاقة بنكية', en: 'Card payment'),
        subtitle: l10n.pick(
          ar: 'ادفع بأمان عبر Mastercard',
          en: 'Pay securely with Mastercard',
        ),
      ),
    ];

    return _Panel(
      title: l10n.pick(ar: 'طريقة الدفع', en: 'Payment method'),
      child: Column(
        children: [
          for (var index = 0; index < methods.length; index++) ...[
            _PaymentTile(
              method: methods[index],
              selected: selectedIndex == index,
              onTap: () => onSelected(index),
            ),
            if (index != methods.length - 1) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}
