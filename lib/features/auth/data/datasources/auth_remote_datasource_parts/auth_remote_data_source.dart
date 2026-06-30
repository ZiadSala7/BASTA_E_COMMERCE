part of '../auth_remote_datasource.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponse> login(LoginRequest request);
  Future<LoginResponse> socialLogin(SocialLoginRequest request);
  Future<RegisterResponse> register(RegisterRequest request);
  Future<String> confirmEmail(String token);
  Future<String> resendConfirmation(String email);
  Future<String> forgotPassword(ForgotPasswordRequest request);
  Future<String> resetPassword(ResetPasswordRequest request);
  Future<String> changePassword(ChangePasswordRequest request);
  Future<ProfileUpdateResponse> updateProfile(UpdateProfileRequest request);
  Future<UserModel> getCurrentUser();
  Future<void> logout();
}
