import '../../domain/entities/order_entity.dart';

extension OrderPaymentState on OrderEntity {
  bool get isUnpaidCardOrder {
    final method = _normalized(paymentMethod);
    final payment = _normalized(paymentStatus);
    if (!method.contains('card') || payment.isEmpty) return false;
    return !const {
      'paid',
      'success',
      'successful',
      'completed',
      'complete',
    }.contains(payment);
  }

  String _normalized(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
  }
}
