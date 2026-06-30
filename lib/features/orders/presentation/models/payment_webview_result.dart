enum PaymentWebViewOutcome { completed, cancelled, failed }

class PaymentWebViewResult {
  const PaymentWebViewResult({
    required this.outcome,
    required this.orderId,
    this.message,
  });

  final PaymentWebViewOutcome outcome;
  final String orderId;
  final String? message;
}
