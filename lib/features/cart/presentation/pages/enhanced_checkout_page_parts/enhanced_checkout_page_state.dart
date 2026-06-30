part of '../enhanced_checkout_page.dart';

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
