import '../../../../core/api/dio_consumer.dart';
import '../../../../core/api/endpoints.dart';
import '../models/product_review_model.dart';

abstract class ProductReviewsRemoteDataSource {
  Future<List<ProductReviewModel>> getProductReviews(String productId);
}

class ProductReviewsRemoteDataSourceImpl
    implements ProductReviewsRemoteDataSource {
  final DioConsumer _dioConsumer;

  const ProductReviewsRemoteDataSourceImpl({required DioConsumer dioConsumer})
    : _dioConsumer = dioConsumer;

  @override
  Future<List<ProductReviewModel>> getProductReviews(String productId) async {
    final response = await _dioConsumer.get(
      Endpoints.productReviews(productId),
    );
    final items = _dataList(response.data);

    return items
        .whereType<Map>()
        .map(
          (item) =>
              ProductReviewModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  List<dynamic> _dataList(dynamic data) {
    if (data is List) return data;

    if (data is Map<String, dynamic>) {
      final direct = data['data'] ?? data['reviews'] ?? data['items'];
      if (direct is List) return direct;

      if (direct is Map<String, dynamic>) {
        final nested =
            direct['reviews'] ?? direct['items'] ?? direct['results'];
        if (nested is List) return nested;
      }
    }

    if (data is Map) {
      return _dataList(Map<String, dynamic>.from(data));
    }

    return const <dynamic>[];
  }
}
