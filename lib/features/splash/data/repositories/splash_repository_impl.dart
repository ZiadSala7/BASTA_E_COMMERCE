import '../../domain/entities/splash_entity.dart';
import '../../domain/repositories/splash_repository.dart';
import '../datasources/splash_local_datasource.dart';

class SplashRepositoryImpl implements SplashRepository {
  final SplashLocalDataSource localDataSource;

  const SplashRepositoryImpl({required this.localDataSource});

  @override
  Future<SplashEntity> getSplashData() async {
    final model = await localDataSource.getSplashData();
    return model;
  }
}
