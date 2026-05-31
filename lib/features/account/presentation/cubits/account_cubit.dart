import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/account_stats_entity.dart';
import '../../domain/usecases/get_account_stats_usecase.dart';

part 'account_state.dart';

class AccountCubit extends Cubit<AccountState> {
  final GetAccountStatsUseCase _getAccountStatsUseCase;

  AccountCubit({
    required GetAccountStatsUseCase getAccountStatsUseCase,
  }) : _getAccountStatsUseCase = getAccountStatsUseCase,
       super(AccountInitial());

  Future<void> getAccountStats() async {
    emit(AccountLoading());
    try {
      final stats = await _getAccountStatsUseCase();
      emit(AccountStatsLoaded(stats));
    } catch (e) {
      emit(AccountError(_mapErrorMessage(e)));
    }
  }

  String _mapErrorMessage(Object error) {
    const exceptionPrefix = 'Exception: ';
    final message = error.toString().trim();
    if (message.startsWith(exceptionPrefix)) {
      return message.substring(exceptionPrefix.length);
    }
    return message;
  }
}