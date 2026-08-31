import '../entities/coupon_entity.dart';

abstract class CouponsRepository {
  Future<List<CouponEntity>> getMyCoupons({int page = 1, int limit = 50});
}
