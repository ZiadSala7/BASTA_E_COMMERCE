part of 'account_cubit.dart';

abstract class AccountState {
  const AccountState();
}

class AccountInitial extends AccountState {}

class AccountLoading extends AccountState {}

class AccountStatsLoaded extends AccountState {
  final AccountStatsEntity stats;

  const AccountStatsLoaded(this.stats);

  List<Object?> get props => [stats];
}

class AccountError extends AccountState {
  final String message;

  const AccountError(this.message);

  List<Object?> get props => [message];
}
