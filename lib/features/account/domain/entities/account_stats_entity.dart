import 'package:equatable/equatable.dart';

class AccountStatsEntity extends Equatable {
  final int ordersCount;
  final int couponsCount;
  final int favoritesCount;

  const AccountStatsEntity({
    required this.ordersCount,
    required this.couponsCount,
    required this.favoritesCount,
  });

  @override
  List<Object?> get props => [ordersCount, couponsCount, favoritesCount];
}
