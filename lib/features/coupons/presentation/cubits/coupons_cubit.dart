import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/coupon_entity.dart';
import '../../domain/usecases/get_my_coupons_usecase.dart';

part 'coupons_state.dart';

class CouponsCubit extends Cubit<CouponsState> {
  final GetMyCouponsUseCase _getMyCouponsUseCase;

  CouponsCubit({required GetMyCouponsUseCase getMyCouponsUseCase})
    : _getMyCouponsUseCase = getMyCouponsUseCase,
      super(CouponsInitial());

  Future<void> getMyCoupons({bool showLoading = true}) async {
    if (showLoading || state is! CouponsLoaded) {
      emit(CouponsLoading());
    }

    try {
      final coupons = await _getMyCouponsUseCase();
      emit(CouponsLoaded(coupons));
    } catch (e) {
      emit(CouponsError(_mapErrorMessage(e)));
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
