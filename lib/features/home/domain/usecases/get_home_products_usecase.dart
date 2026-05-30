import '../entities/home_product_entity.dart';
import '../repositories/home_catalog_repository.dart';

class GetHomeProductsUseCase {
  final HomeCatalogRepository _repository;

  const GetHomeProductsUseCase(this._repository);

  Future<List<HomeProductEntity>> call({
    String? categorySlug,
    String? storeSlug,
    int page = 1,
    int limit = 10,
  }) {
    return _repository.getProducts(
      categorySlug: categorySlug,
      storeSlug: storeSlug,
      page: page,
      limit: limit,
    );
  }
}
