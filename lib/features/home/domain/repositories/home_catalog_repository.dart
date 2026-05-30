import '../entities/home_category_entity.dart';
import '../entities/home_product_entity.dart';
import '../entities/paginated_home_stores_entity.dart';

abstract class HomeCatalogRepository {
  Future<List<HomeCategoryEntity>> getCategories();

  Future<List<HomeProductEntity>> getProducts({
    String? categorySlug,
    String? storeSlug,
    int page = 1,
    int limit = 10,
  });

  Future<PaginatedHomeStoresEntity> getStores({int page = 1, int limit = 10});
}
