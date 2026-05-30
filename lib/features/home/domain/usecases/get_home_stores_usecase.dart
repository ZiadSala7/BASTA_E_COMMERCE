import '../entities/paginated_home_stores_entity.dart';
import '../repositories/home_catalog_repository.dart';

class GetHomeStoresUseCase {
  final HomeCatalogRepository _repository;

  const GetHomeStoresUseCase(this._repository);

  Future<PaginatedHomeStoresEntity> call({int page = 1, int limit = 10}) {
    return _repository.getStores(page: page, limit: limit);
  }
}
