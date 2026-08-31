import '../entities/coupon_entity.dart';
import '../repositories/coupons_repository.dart';

class GetMyCouponsUseCase {
  final CouponsRepository _repository;

  const GetMyCouponsUseCase(this._repository);

  Future<List<CouponEntity>> call({int page = 1, int limit = 50}) {
    return _repository.getMyCoupons(page: page, limit: limit);
  }
}
