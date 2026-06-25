import 'order_entity.dart';
import 'payment_session_entity.dart';

class CheckoutResultEntity {
  final OrderEntity order;
  final PaymentSessionEntity? paymentSession;
  final String message;

  const CheckoutResultEntity({
    required this.order,
    required this.paymentSession,
    required this.message,
  });
}
