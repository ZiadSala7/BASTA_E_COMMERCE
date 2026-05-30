import '../../domain/entities/paginated_home_stores_entity.dart';
import 'home_store_model.dart';

class PaginatedHomeStoresModel extends PaginatedHomeStoresEntity {
  const PaginatedHomeStoresModel({
    required super.stores,
    required super.totalItems,
    required super.totalPages,
    required super.currentPage,
    required super.limit,
  });

  factory PaginatedHomeStoresModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final stores = data is List
        ? data
              .whereType<Map>()
              .map(
                (item) =>
                    HomeStoreModel.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList()
        : const <HomeStoreModel>[];

    return PaginatedHomeStoresModel(
      stores: stores,
      totalItems: _intFromJson(json['totalItems']),
      totalPages: _intFromJson(json['totalPages']),
      currentPage: _intFromJson(json['currentPage'], fallback: 1),
      limit: _intFromJson(json['limit'], fallback: stores.length),
    );
  }

  static int _intFromJson(Object? value, {int fallback = 0}) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? fallback;
  }
}
