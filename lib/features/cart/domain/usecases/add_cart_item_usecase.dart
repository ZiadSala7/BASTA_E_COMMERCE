import '../repositories/cart_repository.dart';
import '../services/cart_badge_controller.dart';

class AddCartItemUseCase {
  final CartRepository _repository;
  final CartBadgeController _cartBadgeController;

  const AddCartItemUseCase(this._repository, this._cartBadgeController);

  Future<void> call({
    String? productId,
    String? variantId,
    int quantity = 1,
  }) async {
    await _repository.addItem(
      productId: productId,
      variantId: variantId,
      quantity: quantity,
    );
    await _cartBadgeController.refresh();
  }
}
