import '../../domain/entities/home_banner_entity.dart';
import '../../domain/entities/home_category_entity.dart';
import '../../domain/entities/home_product_entity.dart';
import '../../domain/entities/home_store_entity.dart';
import '../../domain/entities/paginated_home_stores_entity.dart';
import '../../domain/repositories/home_catalog_repository.dart';
import '../datasources/home_catalog_remote_datasource.dart';

class HomeCatalogRepositoryImpl implements HomeCatalogRepository {
  final HomeCatalogRemoteDataSource _remoteDataSource;

  const HomeCatalogRepositoryImpl({
    required HomeCatalogRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<List<HomeBannerEntity>> getBanners() {
    return _remoteDataSource.getBanners();
  }

  @override
  Future<List<HomeCategoryEntity>> getCategories() {
    return _remoteDataSource.getCategories();
  }

  @override
  Future<List<HomeProductEntity>> getProducts({
    String? categorySlug,
    String? storeSlug,
    String? search,
    int page = 1,
    int limit = 10,
  }) {
    return _remoteDataSource.getProducts(
      categorySlug: categorySlug,
      storeSlug: storeSlug,
      search: search,
      page: page,
      limit: limit,
    );
  }

  @override
  Future<PaginatedHomeStoresEntity> getStores({int page = 1, int limit = 10}) {
    return _remoteDataSource.getStores(page: page, limit: limit);
  }

  @override
  Future<HomeStoreEntity?> getStoreBySlug(String slug) {
    return _remoteDataSource.getStoreBySlug(slug);
  }
}
