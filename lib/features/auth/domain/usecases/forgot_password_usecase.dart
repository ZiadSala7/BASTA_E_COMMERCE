import '../repositories/auth_repository.dart';

class ForgotPasswordUseCase {
  final AuthRepository _repository;

  const ForgotPasswordUseCase(this._repository);

  Future<String> call({required String email}) {
    return _repository.forgotPassword(email);
  }
}
