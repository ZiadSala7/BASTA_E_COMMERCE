part of '../enhanced_checkout_page.dart';

class _OrderSummary extends StatelessWidget {
  const _OrderSummary();

  @override
  Widget build(BuildContext context) {
    return const CustomCard(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _OrderItem(
            name: 'Elegant Summer Dress',
            quantity: 1,
            price: 'JD 89.99',
          ),
          SizedBox(height: 12),
          _OrderItem(
            name: 'Premium Cotton Shirt',
            quantity: 2,
            price: 'JD 91.98',
          ),
          SizedBox(height: 12),
          Divider(height: 1),
          SizedBox(height: 12),
          _OrderTotals(),
        ],
      ),
    );
  }
}
