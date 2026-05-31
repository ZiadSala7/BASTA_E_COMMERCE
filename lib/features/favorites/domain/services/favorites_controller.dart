import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

import '../../data/datasources/favorites_remote_datasource.dart';
import '../../../home/domain/entities/home_product_entity.dart';

class FavoritesController extends ChangeNotifier {
  final FavoritesRemoteDataSource _remoteDataSource;

  FavoritesController(this._remoteDataSource);

  final Set<String> _favoriteProductIds = <String>{};
  final Set<String> _updatingProductIds = <String>{};
  final List<HomeProductEntity> _favoriteProducts = <HomeProductEntity>[];
  bool _isRefreshing = false;

  Set<String> get favoriteProductIds => Set.unmodifiable(_favoriteProductIds);
  Set<String> get updatingProductIds => Set.unmodifiable(_updatingProductIds);
  List<HomeProductEntity> get favoriteProducts =>
      List.unmodifiable(_favoriteProducts);
  bool get isRefreshing => _isRefreshing;

  bool isFavorite(String productId) => _favoriteProductIds.contains(productId);
  bool isUpdating(String productId) => _updatingProductIds.contains(productId);

  Future<void> refresh() async {
    if (_isRefreshing) return;

    _isRefreshing = true;
    await _waitForSafeNotify();
    notifyListeners();
    try {
      final products = await _remoteDataSource.getFavoriteProducts();
      final ids = products.isEmpty
          ? await _remoteDataSource.getFavoriteProductIds()
          : products.map((product) => product.id).toSet();
      _favoriteProductIds
        ..clear()
        ..addAll(ids);
      _favoriteProducts
        ..clear()
        ..addAll(products);
      notifyListeners();
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  Future<void> toggle(String productId) async {
    if (productId.isEmpty || _updatingProductIds.contains(productId)) return;

    final wasFavorite = _favoriteProductIds.contains(productId);
    final removedProduct = wasFavorite
        ? _favoriteProducts
              .where((product) => product.id == productId)
              .firstOrNull
        : null;
    _updatingProductIds.add(productId);
    if (wasFavorite) {
      _favoriteProductIds.remove(productId);
      _favoriteProducts.removeWhere((product) => product.id == productId);
    } else {
      _favoriteProductIds.add(productId);
    }
    notifyListeners();

    try {
      await _remoteDataSource.toggleFavorite(productId);
    } catch (_) {
      if (wasFavorite) {
        _favoriteProductIds.add(productId);
        if (removedProduct != null &&
            !_favoriteProducts.any((product) => product.id == productId)) {
          _favoriteProducts.add(removedProduct);
        }
      } else {
        _favoriteProductIds.remove(productId);
        _favoriteProducts.removeWhere((product) => product.id == productId);
      }
      rethrow;
    } finally {
      _updatingProductIds.remove(productId);
      notifyListeners();
      if (!wasFavorite) {
        await refresh();
      }
    }
  }

  Future<void> _waitForSafeNotify() {
    final phase = SchedulerBinding.instance.schedulerPhase;
    if (phase == SchedulerPhase.idle ||
        phase == SchedulerPhase.postFrameCallbacks) {
      return SynchronousFuture<void>(null);
    }

    return SchedulerBinding.instance.endOfFrame;
  }
}
