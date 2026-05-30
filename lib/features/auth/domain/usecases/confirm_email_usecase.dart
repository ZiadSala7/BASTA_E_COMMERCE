import '../repositories/auth_repository.dart';

class ConfirmEmailUseCase {
  final AuthRepository _repository;

  const ConfirmEmailUseCase(this._repository);

  Future<String> call({required String token}) {
    return _repository.confirmEmail(token);
  }
}
