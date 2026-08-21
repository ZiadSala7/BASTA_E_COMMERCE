import '../entities/product_entity.dart';
import '../repositories/products_repository.dart';

class GetProductDetailsUseCase {
  final ProductsRepository _repository;

  const GetProductDetailsUseCase(this._repository);

  Future<ProductEntity> call(String slugOrId) {
    return _repository.getProductDetails(slugOrId);
  }
}
