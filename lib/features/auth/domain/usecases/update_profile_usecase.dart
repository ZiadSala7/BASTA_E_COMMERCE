import '../entities/profile_update_result.dart';
import '../repositories/auth_repository.dart';

class UpdateProfileUseCase {
  final AuthRepository _repository;

  const UpdateProfileUseCase(this._repository);

  Future<ProfileUpdateResult> call({
    String? name,
    String? phone,
    String? email,
  }) {
    return _repository.updateProfile(name: name, phone: phone, email: email);
  }
}
