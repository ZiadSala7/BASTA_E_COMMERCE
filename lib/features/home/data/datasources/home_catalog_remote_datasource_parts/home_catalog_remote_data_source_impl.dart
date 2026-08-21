part of '../home_catalog_remote_datasource.dart';

class HomeCatalogRemoteDataSourceImpl implements HomeCatalogRemoteDataSource {
  final DioConsumer _dioConsumer;

  const HomeCatalogRemoteDataSourceImpl({required DioConsumer dioConsumer})
      : _dioConsumer = dioConsumer;

  @override
  Future<List<HomeBannerModel>> getBanners() async {
    try {
      final response = await _dioConsumer.get(Endpoints.banners);
      final items = _dataList(response.data);

      return items
          .whereType<Map>()
          .map(
            (item) => HomeBannerModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<List<HomeCategoryModel>> getCategories() async {
    final response = await _dioConsumer.get(Endpoints.categories);
    final items = _dataList(response.data);

    return items
        .whereType<Map>()
        .map(
          (item) => HomeCategoryModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  @override
  Future<List<HomeProductModel>> getProducts({
    String? categorySlug,
    String? storeSlug,
    String? search,
    int page = 1,
    int limit = 10,
  }) async {
    final queryParameters = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (categorySlug != null && categorySlug.isNotEmpty)
        'category': categorySlug,
      if (storeSlug != null && storeSlug.isNotEmpty) 'store': storeSlug,
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
    };

    final response = await _dioConsumer.get(
      Endpoints.products,
      queryParameters: queryParameters,
    );
    final items = _dataList(response.data);

    return items
        .whereType<Map>()
        .map(
          (item) => HomeProductModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  @override
  Future<PaginatedHomeStoresModel> getStores({
    int page = 1,
    int limit = 10,
  }) async {
    final response = await _dioConsumer.get(
      Endpoints.stores,
      queryParameters: {'page': page, 'limit': limit},
    );

    if (response.data is Map<String, dynamic>) {
      return PaginatedHomeStoresModel.fromJson(response.data);
    }

    if (response.data is Map) {
      return PaginatedHomeStoresModel.fromJson(
        Map<String, dynamic>.from(response.data),
      );
    }

    return const PaginatedHomeStoresModel(
      stores: [],
      totalItems: 0,
      totalPages: 0,
      currentPage: 1,
      limit: 10,
    );
  }

  @override
  Future<HomeStoreModel?> getStoreBySlug(String slug) async {
    try {
      final response = await _dioConsumer.get(Endpoints.storeDetails(slug));
      final Map<String, dynamic> body = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : (response.data is Map
              ? Map<String, dynamic>.from(response.data as Map)
              : <String, dynamic>{});

      final storePayload = body['data'] is Map<String, dynamic>
          ? body['data'] as Map<String, dynamic>
          : (body['store'] is Map<String, dynamic>
              ? body['store'] as Map<String, dynamic>
              : body);

      return HomeStoreModel.fromJson(storePayload);
    } catch (_) {
      return null;
    }
  }

  List<dynamic> _dataList(dynamic data) {
    if (data is Map<String, dynamic>) {
      final items = data['data'] ?? data['banners'];
      if (items is List) return items;
      if (items is Map<String, dynamic>) {
        final nestedItems =
            items['products'] ?? items['items'] ?? items['results'] ?? items['banners'];
        if (nestedItems is List) return nestedItems;
      }

      final products = data['products'] ?? data['items'] ?? data['results'];
      if (products is List) return products;
    }

    if (data is Map) {
      final items = data['data'] ?? data['banners'];
      if (items is List) return items;
      if (items is Map) {
        final nestedItems =
            items['products'] ?? items['items'] ?? items['results'] ?? items['banners'];
        if (nestedItems is List) return nestedItems;
      }

      final products = data['products'] ?? data['items'] ?? data['results'];
      if (products is List) return products;
    }

    if (data is List) return data;

    return const [];
  }
}
