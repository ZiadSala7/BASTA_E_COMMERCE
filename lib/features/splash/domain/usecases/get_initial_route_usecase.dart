import '../entities/splash_entity.dart';
import '../repositories/splash_repository.dart';

class GetInitialRouteUseCase {
  final SplashRepository _repository;

  const GetInitialRouteUseCase(this._repository);

  Future<SplashEntity> call() => _repository.getSplashData();
}
