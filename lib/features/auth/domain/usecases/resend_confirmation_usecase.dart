import '../repositories/auth_repository.dart';

class ResendConfirmationUseCase {
  final AuthRepository _repository;

  const ResendConfirmationUseCase(this._repository);

  Future<String> call({required String email}) {
    return _repository.resendConfirmation(email);
  }
}
