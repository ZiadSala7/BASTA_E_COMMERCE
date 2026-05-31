import '../../data/datasources/product_reviews_remote_datasource.dart';
import '../entities/product_review_entity.dart';

class AddProductReviewUseCase {
  final ProductReviewsRemoteDataSource _remoteDataSource;

  const AddProductReviewUseCase(this._remoteDataSource);

  Future<ProductReviewEntity> call({
    required String productId,
    required int rating,
    required String comment,
  }) {
    return _remoteDataSource.addProductReview(
      productId: productId,
      rating: rating,
      comment: comment,
    );
  }
}
