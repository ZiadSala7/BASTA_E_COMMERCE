import 'package:flutter/foundation.dart';

import '../../data/datasources/favorites_remote_datasource.dart';

class FavoritesController extends ChangeNotifier {
  final FavoritesRemoteDataSource _remoteDataSource;

  FavoritesController(this._remoteDataSource);

  final Set<String> _favoriteProductIds = <String>{};
  final Set<String> _updatingProductIds = <String>{};
  bool _isRefreshing = false;

  Set<String> get favoriteProductIds => Set.unmodifiable(_favoriteProductIds);
  Set<String> get updatingProductIds => Set.unmodifiable(_updatingProductIds);

  bool isFavorite(String productId) => _favoriteProductIds.contains(productId);
  bool isUpdating(String productId) => _updatingProductIds.contains(productId);

  Future<void> refresh() async {
    if (_isRefreshing) return;

    _isRefreshing = true;
    try {
      final ids = await _remoteDataSource.getFavoriteProductIds();
      _favoriteProductIds
        ..clear()
        ..addAll(ids);
      notifyListeners();
    } finally {
      _isRefreshing = false;
    }
  }

  Future<void> toggle(String productId) async {
    if (productId.isEmpty || _updatingProductIds.contains(productId)) return;

    final wasFavorite = _favoriteProductIds.contains(productId);
    _updatingProductIds.add(productId);
    if (wasFavorite) {
      _favoriteProductIds.remove(productId);
    } else {
      _favoriteProductIds.add(productId);
    }
    notifyListeners();

    try {
      await _remoteDataSource.toggleFavorite(productId);
    } catch (_) {
      if (wasFavorite) {
        _favoriteProductIds.add(productId);
      } else {
        _favoriteProductIds.remove(productId);
      }
      rethrow;
    } finally {
      _updatingProductIds.remove(productId);
      notifyListeners();
    }
  }
}
