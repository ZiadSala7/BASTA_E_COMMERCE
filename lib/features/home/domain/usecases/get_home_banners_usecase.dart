import '../entities/home_banner_entity.dart';
import '../repositories/home_catalog_repository.dart';

class GetHomeBannersUseCase {
  final HomeCatalogRepository _repository;

  const GetHomeBannersUseCase({required HomeCatalogRepository repository})
      : _repository = repository;

  Future<List<HomeBannerEntity>> call() {
    return _repository.getBanners();
  }
}
