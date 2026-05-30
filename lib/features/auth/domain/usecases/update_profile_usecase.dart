import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class UpdateProfileUseCase {
  final AuthRepository _repository;

  const UpdateProfileUseCase(this._repository);

  Future<UserEntity> call({String? name, String? phone, String? email}) {
    return _repository.updateProfile(name: name, phone: phone, email: email);
  }
}
