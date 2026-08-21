import '../entities/order_entity.dart';
import '../entities/checkout_result_entity.dart';

abstract class OrdersRepository {
  Future<List<OrderEntity>> getMyOrders();

  Future<OrderEntity?> getOrderById(String orderId);

  Future<String?> getOrderInvoiceUrl(String orderId);

  Future<CheckoutResultEntity> checkout({
    required Map<String, dynamic> address,
    required String paymentMethod,
    String? couponCode,
  });

  Future<OrderEntity> verifyPayment(String orderId);

  Future<void> cancelPayment(String orderId);
}
