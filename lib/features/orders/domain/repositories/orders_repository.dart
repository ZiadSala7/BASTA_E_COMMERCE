import '../entities/order_entity.dart';
import '../entities/checkout_result_entity.dart';

abstract class OrdersRepository {
  Future<List<OrderEntity>> getMyOrders();

  Future<CheckoutResultEntity> checkout({
    required Map<String, dynamic> address,
    required String paymentMethod,
  });

  Future<OrderEntity> verifyPayment(String orderId);
}
