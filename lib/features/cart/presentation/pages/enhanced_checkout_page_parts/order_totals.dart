part of '../enhanced_checkout_page.dart';

class _OrderTotals extends StatelessWidget {
  const _OrderTotals();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _TotalRow(label: 'Subtotal', value: 'JD 189.98'),
        SizedBox(height: 6),
        _TotalRow(label: 'Shipping', value: 'JD 5.00'),
        SizedBox(height: 6),
        _TotalRow(label: 'Tax', value: 'JD 15.00'),
        SizedBox(height: 12),
        Divider(height: 1),
        SizedBox(height: 8),
        _TotalRow(
          label: 'Total',
          value: 'JD 209.98',
          isBold: true,
          isHighlighted: true,
        ),
      ],
    );
  }
}
