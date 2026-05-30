import '../entities/home_category_entity.dart';
import '../repositories/home_catalog_repository.dart';

class GetHomeCategoriesUseCase {
  final HomeCatalogRepository _repository;

  const GetHomeCategoriesUseCase(this._repository);

  Future<List<HomeCategoryEntity>> call() {
    return _repository.getCategories();
  }
}
