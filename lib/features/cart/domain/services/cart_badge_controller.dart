import 'package:flutter/foundation.dart';

import '../entities/cart_item_entity.dart';
import '../repositories/cart_repository.dart';

class CartBadgeController extends ChangeNotifier {
  final CartRepository _repository;

  CartBadgeController(this._repository);

  int _itemCount = 0;
  bool _isRefreshing = false;

  int get itemCount => _itemCount;

  Future<void> refresh() async {
    if (_isRefreshing) return;

    _isRefreshing = true;
    try {
      final items = await _repository.getCartItems();
      setItems(items);
    } catch (_) {
      // Keep the previous badge count if the refresh fails.
    } finally {
      _isRefreshing = false;
    }
  }

  void setItems(Iterable<CartItemEntity> items) {
    setCount(items.fold<int>(0, (total, item) => total + item.quantity));
  }

  void setCount(int count) {
    final safeCount = count < 0 ? 0 : count;
    if (_itemCount == safeCount) return;

    _itemCount = safeCount;
    notifyListeners();
  }
}
