part of '../home_catalog_remote_datasource.dart';

abstract class HomeCatalogRemoteDataSource {
  Future<List<HomeBannerModel>> getBanners();

  Future<List<HomeCategoryModel>> getCategories();

  Future<List<HomeProductModel>> getProducts({
    String? categorySlug,
    String? storeSlug,
    String? search,
    int page = 1,
    int limit = 10,
  });

  Future<PaginatedHomeStoresModel> getStores({int page = 1, int limit = 10});

  Future<HomeStoreModel?> getStoreBySlug(String slug);
}
