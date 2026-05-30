import '../repositories/auth_repository.dart';

class ChangePasswordUseCase {
  final AuthRepository _repository;

  const ChangePasswordUseCase(this._repository);

  Future<String> call({
    required String oldPassword,
    required String newPassword,
  }) {
    return _repository.changePassword(oldPassword, newPassword);
  }
}
