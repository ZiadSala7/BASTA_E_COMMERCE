enum PaymentWebViewOutcome { completed, cancelled, failed }

class PaymentWebViewResult {
  const PaymentWebViewResult({
    required this.outcome,
    required this.orderId,
    this.message,
    this.resultIndicator,
  });

  final PaymentWebViewOutcome outcome;
  final String orderId;
  final String? message;
  final String? resultIndicator;
}
