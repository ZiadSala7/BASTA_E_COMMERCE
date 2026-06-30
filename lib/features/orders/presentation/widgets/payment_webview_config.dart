class PaymentWebViewConfig {
  static const scriptUrl = String.fromEnvironment(
    'MPGS_CHECKOUT_JS_URL',
    defaultValue:
        'https://test-network.mtf.gateway.mastercard.com/static/checkout/checkout.min.js',
  );
  static const currency = String.fromEnvironment(
    'MPGS_CURRENCY',
    defaultValue: 'JOD',
  );
  static const merchantName = String.fromEnvironment(
    'MPGS_MERCHANT_NAME',
    defaultValue: 'Bs6a',
  );
  static const merchantAddress = String.fromEnvironment(
    'MPGS_MERCHANT_ADDRESS',
    defaultValue: 'Amman, Jordan',
  );
  static const orderDescription = String.fromEnvironment(
    'MPGS_ORDER_DESCRIPTION',
    defaultValue: 'Bs6a E-Commerce Order',
  );
}
