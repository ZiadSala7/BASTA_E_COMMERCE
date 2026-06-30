part of '../favorites_remote_datasource.dart';

abstract class FavoritesRemoteDataSource {
  Future<Set<String>> getFavoriteProductIds();
  Future<List<HomeProductEntity>> getFavoriteProducts();
  Future<void> toggleFavorite(String productId);
}
