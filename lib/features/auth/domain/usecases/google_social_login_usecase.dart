import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class GoogleSocialLoginUseCase {
  final AuthRepository _repository;

  const GoogleSocialLoginUseCase(this._repository);

  Future<UserEntity> call({bool rememberSession = true}) {
    return _repository.loginWithGoogle(rememberSession: rememberSession);
  }
}
