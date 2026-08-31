import '../../domain/entities/coupon_entity.dart';
import '../../domain/repositories/coupons_repository.dart';
import '../datasources/coupons_remote_datasource.dart';

class CouponsRepositoryImpl implements CouponsRepository {
  final CouponsRemoteDataSource _remoteDataSource;

  const CouponsRepositoryImpl({
    required CouponsRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<List<CouponEntity>> getMyCoupons({
    int page = 1,
    int limit = 50,
  }) async {
    return await _remoteDataSource.getMyCoupons(page: page, limit: limit);
  }
}
