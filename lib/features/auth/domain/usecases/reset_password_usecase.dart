import '../repositories/auth_repository.dart';

class ResetPasswordUseCase {
  final AuthRepository _repository;

  const ResetPasswordUseCase(this._repository);

  Future<String> call({required String token, required String newPassword}) {
    return _repository.resetPassword(token, newPassword);
  }
}
