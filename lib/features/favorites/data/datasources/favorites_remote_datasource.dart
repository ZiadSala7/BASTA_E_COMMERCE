import '../../../../core/api/dio_consumer.dart';
import '../../../../core/api/endpoints.dart';

abstract class FavoritesRemoteDataSource {
  Future<Set<String>> getFavoriteProductIds();
  Future<void> toggleFavorite(String productId);
}

class FavoritesRemoteDataSourceImpl implements FavoritesRemoteDataSource {
  final DioConsumer _dioConsumer;

  const FavoritesRemoteDataSourceImpl({required DioConsumer dioConsumer})
    : _dioConsumer = dioConsumer;

  @override
  Future<Set<String>> getFavoriteProductIds() async {
    final response = await _dioConsumer.get(Endpoints.favorites);
    return _dataList(
      response.data,
    ).map(_productIdFromFavorite).where((id) => id.isNotEmpty).toSet();
  }

  @override
  Future<void> toggleFavorite(String productId) async {
    await _dioConsumer.post(
      Endpoints.toggleFavorite,
      data: {'productId': productId},
    );
  }

  List<dynamic> _dataList(dynamic data) {
    if (data is List) return data;

    if (data is Map<String, dynamic>) {
      final direct =
          data['data'] ??
          data['favorites'] ??
          data['items'] ??
          data['products'];
      if (direct is List) return direct;

      if (direct is Map<String, dynamic>) {
        final nested =
            direct['favorites'] ?? direct['items'] ?? direct['products'];
        if (nested is List) return nested;
      }
    }

    if (data is Map) {
      return _dataList(Map<String, dynamic>.from(data));
    }

    return const <dynamic>[];
  }

  String _productIdFromFavorite(dynamic item) {
    if (item is String) return item;
    if (item is! Map) return '';

    final favorite = Map<String, dynamic>.from(item);
    final rawProduct = favorite['product'];
    final product = rawProduct is Map
        ? Map<String, dynamic>.from(rawProduct)
        : null;

    return (favorite['productId'] ??
            favorite['product_id'] ??
            (rawProduct is Map ? null : rawProduct) ??
            product?['id'] ??
            product?['_id'] ??
            favorite['id'] ??
            favorite['_id'] ??
            '')
        .toString();
  }
}
