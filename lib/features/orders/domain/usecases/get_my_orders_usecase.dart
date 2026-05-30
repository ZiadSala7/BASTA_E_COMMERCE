import '../entities/order_entity.dart';
import '../repositories/orders_repository.dart';

class GetMyOrdersUseCase {
  final OrdersRepository _repository;

  const GetMyOrdersUseCase(this._repository);

  Future<List<OrderEntity>> call() {
    return _repository.getMyOrders();
  }
}
