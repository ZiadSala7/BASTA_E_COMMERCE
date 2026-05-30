import 'home_store_entity.dart';

class PaginatedHomeStoresEntity {
  final List<HomeStoreEntity> stores;
  final int totalItems;
  final int totalPages;
  final int currentPage;
  final int limit;

  const PaginatedHomeStoresEntity({
    required this.stores,
    required this.totalItems,
    required this.totalPages,
    required this.currentPage,
    required this.limit,
  });

  bool get hasMore => currentPage < totalPages;
}
