import '../../domain/entities/account_stats_entity.dart';

class AccountStatsModel extends AccountStatsEntity {
  const AccountStatsModel({
    required super.ordersCount,
    required super.couponsCount,
    required super.favoritesCount,
  });

  factory AccountStatsModel.fromJson(Map<String, dynamic> json) {
    return AccountStatsModel(
      ordersCount: json['ordersCount'] ?? 0,
      couponsCount: json['couponsCount'] ?? 0,
      favoritesCount: json['favoritesCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ordersCount': ordersCount,
      'couponsCount': couponsCount,
      'favoritesCount': favoritesCount,
    };
  }
}
