import '../entities/account_stats_entity.dart';
import '../repositories/account_repository.dart';

class GetAccountStatsUseCase {
  final AccountRepository _repository;

  const GetAccountStatsUseCase(this._repository);

  Future<AccountStatsEntity> call() {
    return _repository.getAccountStats();
  }
}
