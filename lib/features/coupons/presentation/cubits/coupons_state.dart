part of 'coupons_cubit.dart';

abstract class CouponsState extends Equatable {
  const CouponsState();

  @override
  List<Object?> get props => [];
}

class CouponsInitial extends CouponsState {}

class CouponsLoading extends CouponsState {}

class CouponsLoaded extends CouponsState {
  final List<CouponEntity> coupons;

  const CouponsLoaded(this.coupons);

  List<CouponEntity> get activeCoupons =>
      coupons.where((c) => c.isValid).toList();

  List<CouponEntity> get inactiveCoupons =>
      coupons.where((c) => !c.isValid).toList();

  @override
  List<Object?> get props => [coupons];
}

class CouponsError extends CouponsState {
  final String message;

  const CouponsError(this.message);

  @override
  List<Object?> get props => [message];
}
