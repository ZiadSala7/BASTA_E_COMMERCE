import '../../domain/entities/order_entity.dart';
import '../../domain/entities/checkout_result_entity.dart';
import '../../domain/repositories/orders_repository.dart';
import '../datasources/orders_remote_datasource.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  final OrdersRemoteDataSource _remoteDataSource;

  const OrdersRepositoryImpl({required OrdersRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  @override
  Future<List<OrderEntity>> getMyOrders() {
    return _remoteDataSource.getMyOrders();
  }

  @override
  Future<OrderEntity?> getOrderById(String orderId) {
    return _remoteDataSource.getOrderById(orderId);
  }

  @override
  Future<String?> getOrderInvoiceUrl(String orderId) {
    return _remoteDataSource.getOrderInvoiceUrl(orderId);
  }

  @override
  Future<CheckoutResultEntity> checkout({
    required Map<String, dynamic> address,
    required String paymentMethod,
    String? couponCode,
  }) {
    return _remoteDataSource.checkout(
      address: address,
      paymentMethod: paymentMethod,
      couponCode: couponCode,
    );
  }

  @override
  Future<OrderEntity> verifyPayment(String orderId) {
    return _remoteDataSource.verifyPayment(orderId);
  }

  @override
  Future<void> cancelPayment(String orderId) {
    return _remoteDataSource.cancelPayment(orderId);
  }
}
