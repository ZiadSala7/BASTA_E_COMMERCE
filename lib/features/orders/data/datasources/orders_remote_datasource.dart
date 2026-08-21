import '../../../../core/api/dio_consumer.dart';
import '../models/checkout_result_model.dart';
import '../models/order_model.dart';
import 'checkout_api_client.dart';
import 'orders_api_client.dart';
import 'payment_verification_api_client.dart';

abstract class OrdersRemoteDataSource {
  Future<List<OrderModel>> getMyOrders();

  Future<OrderModel?> getOrderById(String orderId);

  Future<String?> getOrderInvoiceUrl(String orderId);

  Future<CheckoutResultModel> checkout({
    required Map<String, dynamic> address,
    required String paymentMethod,
    String? couponCode,
  });

  Future<OrderModel> verifyPayment(String orderId);

  Future<void> cancelPayment(String orderId);
}

class OrdersRemoteDataSourceImpl implements OrdersRemoteDataSource {
  OrdersRemoteDataSourceImpl({required DioConsumer dioConsumer})
    : _orders = OrdersApiClient(dioConsumer),
      _checkout = CheckoutApiClient(dioConsumer),
      _verification = PaymentVerificationApiClient(dioConsumer);

  final OrdersApiClient _orders;
  final CheckoutApiClient _checkout;
  final PaymentVerificationApiClient _verification;

  @override
  Future<List<OrderModel>> getMyOrders() => _orders.getMyOrders();

  @override
  Future<OrderModel?> getOrderById(String orderId) =>
      _orders.getOrderById(orderId);

  @override
  Future<String?> getOrderInvoiceUrl(String orderId) =>
      _orders.getOrderInvoiceUrl(orderId);

  @override
  Future<CheckoutResultModel> checkout({
    required Map<String, dynamic> address,
    required String paymentMethod,
    String? couponCode,
  }) => _checkout.checkout(
    address: address,
    paymentMethod: paymentMethod,
    couponCode: couponCode,
  );

  @override
  Future<OrderModel> verifyPayment(String orderId) {
    return _verification.verify(orderId);
  }

  @override
  Future<void> cancelPayment(String orderId) {
    return _verification.cancel(orderId);
  }
}
