part of '../product_reviews_remote_datasource.dart';

class ProductReviewsRemoteDataSourceImpl
    implements ProductReviewsRemoteDataSource {
  final DioConsumer _dioConsumer;

  const ProductReviewsRemoteDataSourceImpl({required DioConsumer dioConsumer})
    : _dioConsumer = dioConsumer;

  @override
  Future<List<ProductReviewModel>> getProductReviews(String productId) async {
    try {
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
    } on DioException catch (error) {
      throw Exception(_messageFromDio(error));
    }
  }

  @override
  Future<ProductReviewModel> addProductReview({
    required String productId,
    required int rating,
    required String comment,
  }) async {
    try {
      final response = await _dioConsumer.post(
        Endpoints.productReviews(productId),
        data: {'rating': rating, 'comment': comment},
      );
      final payload = _reviewPayload(response.data);

      if (payload.isEmpty) {
        return ProductReviewModel.fromJson({
          'rating': rating,
          'comment': comment,
        });
      }

      return ProductReviewModel.fromJson(payload);
    } on DioException catch (error) {
      throw Exception(_messageFromDio(error));
    }
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

  Map<String, dynamic> _reviewPayload(dynamic data) {
    if (data is Map<String, dynamic>) {
      final direct = data['data'] ?? data['review'] ?? data['item'];
      if (direct is Map<String, dynamic>) return direct;

      if (direct is Map) return Map<String, dynamic>.from(direct);

      return data;
    }

    if (data is Map) return Map<String, dynamic>.from(data);

    return <String, dynamic>{};
  }

  String _messageFromDio(DioException error) {
    final map = _asMap(error.response?.data);
    final message = map['message']?.toString().trim();
    if (message != null && message.isNotEmpty) return message;

    final errorValue = map['error']?.toString().trim();
    if (errorValue != null && errorValue.isNotEmpty) return errorValue;

    return error.message ?? 'Review request failed.';
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, item) => MapEntry(key.toString(), item));
    }
    return <String, dynamic>{};
  }
}
