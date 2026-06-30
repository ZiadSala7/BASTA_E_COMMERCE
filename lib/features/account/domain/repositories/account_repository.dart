import '../entities/account_stats_entity.dart';

abstract class AccountRepository {
  Future<AccountStatsEntity> getAccountStats();
}
