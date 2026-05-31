import '../../domain/entities/account_stats_entity.dart';
import '../../domain/repositories/account_repository.dart';
import '../datasources/account_remote_datasource.dart';

class AccountRepositoryImpl implements AccountRepository {
  final AccountRemoteDataSource _remoteDataSource;

  AccountRepositoryImpl({required AccountRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<AccountStatsEntity> getAccountStats() async {
    final statsModel = await _remoteDataSource.getAccountStats();
    return AccountStatsEntity(
      ordersCount: statsModel.ordersCount,
      couponsCount: statsModel.couponsCount,
      favoritesCount: statsModel.favoritesCount,
    );
  }
}