import '../../data/datasources/product_reviews_remote_datasource.dart';
import '../entities/product_review_entity.dart';

class GetProductReviewsUseCase {
  final ProductReviewsRemoteDataSource _remoteDataSource;

  const GetProductReviewsUseCase(this._remoteDataSource);

  Future<List<ProductReviewEntity>> call(String productId) {
    return _remoteDataSource.getProductReviews(productId);
  }
}
