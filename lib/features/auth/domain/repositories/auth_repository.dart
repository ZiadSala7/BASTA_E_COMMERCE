import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login(
    String email,
    String password, {
    bool rememberSession = true,
  });
  Future<UserEntity> register(
    String email,
    String password,
    String name,
    String phone,
  );
  Future<String> forgotPassword(String email);
  Future<UserEntity> getCurrentUser();
  Future<void> logout();
}
