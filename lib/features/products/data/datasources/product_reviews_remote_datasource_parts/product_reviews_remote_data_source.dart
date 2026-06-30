part of '../product_reviews_remote_datasource.dart';

abstract class ProductReviewsRemoteDataSource {
  Future<List<ProductReviewModel>> getProductReviews(String productId);
  Future<ProductReviewModel> addProductReview({
    required String productId,
    required int rating,
    required String comment,
  });
}
