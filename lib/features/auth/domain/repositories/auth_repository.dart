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
    String role,
  );
  Future<String> confirmEmail(String token);
  Future<String> resendConfirmation(String email);
  Future<String> forgotPassword(String email);
  Future<String> resetPassword(String token, String newPassword);
  Future<String> changePassword(String oldPassword, String newPassword);
  Future<UserEntity> updateProfile({
    String? name,
    String? phone,
    String? email,
  });
  Future<UserEntity> getCurrentUser();
  Future<void> logout();
}
