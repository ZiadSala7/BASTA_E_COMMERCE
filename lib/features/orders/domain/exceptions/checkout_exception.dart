class CheckoutException implements Exception {
  const CheckoutException({
    required this.message,
    this.errorName,
    this.productId,
    this.statusCode,
  });

  final String message;
  final String? errorName;
  final String? productId;
  final int? statusCode;

  bool get isInsufficientStock =>
      errorName == 'InsufficientStockError' && productId?.isNotEmpty == true;

  @override
  String toString() => message;
}
