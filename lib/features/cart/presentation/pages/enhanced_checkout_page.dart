// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/widgets/common/custom_app_bar.dart';
import '../../../../core/widgets/common/custom_card.dart';
import '../../../../core/widgets/common/section_header.dart';
import '../../../../core/widgets/common/selectable_tile.dart';

class EnhancedCheckoutPage extends StatefulWidget {
  const EnhancedCheckoutPage({super.key});

  @override
  State<EnhancedCheckoutPage> createState() => _EnhancedCheckoutPageState();
}

class _EnhancedCheckoutPageState extends State<EnhancedCheckoutPage> {
  int _selectedPaymentMethod = 0;
  int _selectedShippingAddress = 0;

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'icon': Icons.credit_card,
      'label': 'Credit Card',
      'description': 'Visa, MasterCard, American Express',
    },
    {
      'icon': Icons.account_balance_wallet,
      'label': 'Digital Wallet',
      'description': 'Apple Pay, Google Pay',
    },
    {
      'icon': Icons.money,
      'label': 'Cash on Delivery',
      'description': 'Pay when you receive',
    },
  ];

  final List<Map<String, dynamic>> _shippingAddresses = [
    {
      'name': 'Home Address',
      'address': '123 Main Street, Amman, Jordan',
      'phone': '+962 7 1234 5678',
      'isDefault': true,
    },
    {
      'name': 'Work Address',
      'address': '456 Business District, Amman, Jordan',
      'phone': '+962 7 9876 5432',
      'isDefault': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'Checkout',
        centerTitle: true,
        showSearch: false,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order Summary
                  const SectionHeader(
                    title: 'Order Summary',
                    subtitle: '2 items from 2 vendors',
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 12),
                  const _OrderSummary(),
                  const SizedBox(height: 24),

                  // Shipping Address
                  SectionHeader(
                    title: 'Shipping Address',
                    actionLabel: 'Add New',
                    onActionTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Address form coming soon'),
                        ),
                      );
                    },
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 12),
                  _ShippingAddressSection(
                    addresses: _shippingAddresses,
                    selected: _selectedShippingAddress,
                    onChanged: (index) =>
                        setState(() => _selectedShippingAddress = index),
                  ),
                  const SizedBox(height: 24),

                  // Payment Method
                  const SectionHeader(
                    title: 'Payment Method',
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 12),
                  _PaymentMethodSection(
                    methods: _paymentMethods,
                    selected: _selectedPaymentMethod,
                    onChanged: (index) =>
                        setState(() => _selectedPaymentMethod = index),
                  ),
                  const SizedBox(height: 24),

                  // Promo Code
                  const SectionHeader(
                    title: 'Promo Code',
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 12),
                  const _PromoCodeSection(),
                ],
              ),
            ),
          ),
          // Bottom Action Bar
          _CheckoutActionBar(
            subtotal: 'JD 189.98',
            shipping: 'JD 5.00',
            total: 'JD 209.98',
            onPlaceOrder: _placeOrder,
          ),
        ],
      ),
    );
  }

  void _placeOrder() {
    // Show success dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _OrderSuccessDialog(),
    );
  }
}

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

class _OrderItem extends StatelessWidget {
  final String name;
  final int quantity;
  final String price;

  const _OrderItem({
    required this.name,
    required this.quantity,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(child: Icon(Icons.image, color: Colors.grey)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'Qty: $quantity',
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
        Text(
          price,
          style: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

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

class _TotalRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final bool isHighlighted;

  const _TotalRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
            color: isHighlighted ? AppColors.primary : null,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: isHighlighted ? AppColors.primary : null,
          ),
        ),
      ],
    );
  }
}

class _ShippingAddressSection extends StatelessWidget {
  final List<Map<String, dynamic>> addresses;
  final int selected;
  final ValueChanged<int> onChanged;

  const _ShippingAddressSection({
    required this.addresses,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: addresses.asMap().entries.map((entry) {
        final index = entry.key;
        final address = entry.value;
        final isSelected = index == selected;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: SelectableTile(
            onTap: () => onChanged(index),
            selected: isSelected,
            leading: Icon(
              Icons.location_on_outlined,
              color: isSelected ? AppColors.primary : const Color(0xFF6B7280),
            ),
            title: address['name'],
            subtitle: '${address['address']}\n${address['phone']}',
          ),
        );
      }).toList(),
    );
  }
}

class _PaymentMethodSection extends StatelessWidget {
  final List<Map<String, dynamic>> methods;
  final int selected;
  final ValueChanged<int> onChanged;

  const _PaymentMethodSection({
    required this.methods,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: methods.asMap().entries.map((entry) {
        final index = entry.key;
        final method = entry.value;
        final isSelected = index == selected;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: SelectableTile(
            onTap: () => onChanged(index),
            selected: isSelected,
            leading: Icon(
              method['icon'],
              color: isSelected ? AppColors.primary : const Color(0xFF6B7280),
            ),
            title: method['label'],
            subtitle: method['description'],
          ),
        );
      }).toList(),
    );
  }
}

class _PromoCodeSection extends StatelessWidget {
  const _PromoCodeSection();

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Enter promo code',
                hintStyle: GoogleFonts.cairo(
                  color: const Color(0xFF9CA3AF),
                  fontSize: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            height: 42,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Apply',
                style: GoogleFonts.cairo(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckoutActionBar extends StatelessWidget {
  final String subtotal;
  final String shipping;
  final String total;
  final VoidCallback onPlaceOrder;

  const _CheckoutActionBar({
    required this.subtotal,
    required this.shipping,
    required this.total,
    required this.onPlaceOrder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Subtotal',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                Text(
                  '$subtotal + $shipping shipping',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  total,
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: onPlaceOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Place Order',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderSuccessDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Color(0xFF4CAF50),
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Order Placed!',
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your order has been placed successfully. You will receive a confirmation email shortly.',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Continue Shopping',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
