import '../services/cart_badge_controller.dart';
import '../repositories/cart_repository.dart';

class AddCartItemUseCase {
  final CartRepository _repository;
  final CartBadgeController _cartBadgeController;

  const AddCartItemUseCase(this._repository, this._cartBadgeController);

  Future<void> call({required String productId, int quantity = 1}) async {
    await _repository.addItem(productId: productId, quantity: quantity);
    await _cartBadgeController.refresh();
  }
}
