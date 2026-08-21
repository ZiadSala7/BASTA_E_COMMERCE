import 'dart:convert';

import '../../domain/entities/user_entity.dart';
import '../../domain/entities/profile_update_result.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/firebase_social_auth_datasource.dart';
import '../models/change_password_request.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/forgot_password_request.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/register_request.dart';
import '../models/reset_password_request.dart';
import '../models/social_login_request.dart';
import '../models/update_profile_request.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;
  final FirebaseSocialAuthDataSource _firebaseSocialAuthDataSource;

  const AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
    required FirebaseSocialAuthDataSource firebaseSocialAuthDataSource,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource,
       _firebaseSocialAuthDataSource = firebaseSocialAuthDataSource;

  @override
  Future<UserEntity> login(
    String email,
    String password, {
    bool rememberSession = true,
  }) async {
    final loginResponse = await _remoteDataSource.login(
      LoginRequest(email: email, password: password),
    );

    return _persistLoginResponse(
      loginResponse,
      rememberSession: rememberSession,
    );
  }

  @override
  Future<UserEntity> loginWithGoogle({bool rememberSession = true}) async {
    final firebaseIdToken = await _firebaseSocialAuthDataSource
        .getGoogleFirebaseIdToken();
    final loginResponse = await _remoteDataSource.socialLogin(
      SocialLoginRequest(idToken: firebaseIdToken, role: 'CUSTOMER'),
    );

    return _persistLoginResponse(
      loginResponse,
      rememberSession: rememberSession,
    );
  }

  Future<UserEntity> _persistLoginResponse(
    LoginResponse loginResponse, {
    required bool rememberSession,
  }) async {
    await _localDataSource.clearUser();
    await _localDataSource.saveToken(
      loginResponse.token,
      persist: rememberSession,
    );

    final loginUser = loginResponse.user.copyWith(token: loginResponse.token);
    await _localDataSource.saveUser(
      UserModel.fromEntity(loginUser),
      persist: rememberSession,
    );

    final user = await _userForActiveSession(loginUser, loginResponse.token);
    await _localDataSource.saveUser(
      UserModel.fromEntity(user),
      persist: rememberSession,
    );

    return user;
  }

  @override
  Future<UserEntity> register(
    String email,
    String password,
    String name,
    String phone,
    String role, {
    String? couponCode,
    String? referralCode,
  }) async {
    final registerResponse = await _remoteDataSource.register(
      RegisterRequest(
        email: email,
        password: password,
        name: name,
        phone: phone,
        role: role,
        couponCode: couponCode,
        referralCode: referralCode,
      ),
    );

    return registerResponse.user;
  }

  @override
  Future<String> confirmEmail(String token) {
    return _remoteDataSource.confirmEmail(token);
  }

  @override
  Future<String> resendConfirmation(String email) {
    return _remoteDataSource.resendConfirmation(email);
  }

  @override
  Future<String> forgotPassword(String email) {
    return _remoteDataSource.forgotPassword(
      ForgotPasswordRequest(email: email),
    );
  }

  @override
  Future<String> resetPassword(String token, String newPassword) {
    return _remoteDataSource.resetPassword(
      ResetPasswordRequest(token: token, newPassword: newPassword),
    );
  }

  @override
  Future<String> changePassword(String oldPassword, String newPassword) {
    return _remoteDataSource.changePassword(
      ChangePasswordRequest(oldPassword: oldPassword, newPassword: newPassword),
    );
  }

  @override
  Future<ProfileUpdateResult> updateProfile({
    String? name,
    String? phone,
    String? email,
  }) async {
    final request = UpdateProfileRequest(
      name: name,
      phone: phone,
      email: email,
    );
    if (request.toJson().isEmpty) {
      throw Exception('Please change at least one profile field.');
    }

    final token = await _localDataSource.getToken();
    final cachedUser = await _localDataSource.getUser();
    final response = await _remoteDataSource.updateProfile(request);
    final user = _mergeUser(
      primary: response.user,
      fallback: cachedUser,
      token: token ?? response.user.token ?? cachedUser?.token ?? '',
    );

    final emailChanged = _isChangedEmail(email, cachedUser?.email);
    final needsVerification =
        emailChanged || response.requiresEmailVerification;

    if (needsVerification) {
      try {
        await _firebaseSocialAuthDataSource.signOut();
      } catch (_) {}
      await _localDataSource.clearToken();
      await _localDataSource.clearUser();

      return ProfileUpdateResult(
        user: UserEntity(
          id: user.id,
          email: user.email,
          name: user.name,
          phone: user.phone,
          role: user.role,
          status: user.status,
          referralCode: user.referralCode,
        ),
        message:
            response.message ??
            'Profile updated. Please verify your new email before logging in again.',
        emailVerificationRequired: true,
      );
    }

    await _localDataSource.saveUser(UserModel.fromEntity(user));
    return ProfileUpdateResult(user: user, message: response.message);
  }

  @override
  Future<UserEntity> getCurrentUser() async {
    final token = await _localDataSource.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('No active session found.');
    }

    if (token == 'mock_google_session') {
      return const UserEntity(
        id: 'mock-google-user',
        email: 'google.user@basta.app',
        name: 'Google User',
        role: 'CUSTOMER',
        status: 'ACTIVE',
        token: 'mock_google_session',
      );
    }

    try {
      final user = await _remoteDataSource.getCurrentUser();
      final cachedUser = await _localDataSource.getUser();
      final userWithToken = _mergeUser(
        primary: user,
        fallback: cachedUser,
        token: token,
      );
      await _localDataSource.saveUser(UserModel.fromEntity(userWithToken));
      return userWithToken;
    } catch (error) {
      final cachedUser = await _localDataSource.getUser();
      if (cachedUser != null) {
        return cachedUser.copyWith(token: token);
      }

      final tokenUser = _userFromToken(token);
      if (tokenUser != null) {
        return tokenUser;
      }

      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _remoteDataSource.logout();
    } catch (_) {
      // Stateless JWT logout is satisfied once the local token is cleared.
    } finally {
      try {
        await _firebaseSocialAuthDataSource.signOut();
      } catch (_) {
        // Local session clearing must still complete if Firebase sign-out fails.
      }
      await _localDataSource.clearToken();
      await _localDataSource.clearUser();
    }
  }

  UserEntity? _userFromToken(String token) {
    final parts = token.split('.');
    if (parts.length != 3) return null;

    try {
      final normalizedPayload = base64Url.normalize(parts[1]);
      final payload = utf8.decode(base64Url.decode(normalizedPayload));
      final decoded = jsonDecode(payload);
      if (decoded is! Map) return null;

      return UserEntity(
        id: decoded['id']?.toString() ?? '',
        email: '',
        name: '',
        role: decoded['role']?.toString(),
        token: token,
      );
    } catch (_) {
      return null;
    }
  }

  Future<UserEntity> _userForActiveSession(
    UserEntity loginUser,
    String token,
  ) async {
    try {
      final currentUser = await _remoteDataSource.getCurrentUser();
      return _mergeUser(
        primary: currentUser,
        fallback: loginUser,
        token: token,
      );
    } catch (_) {
      return loginUser.copyWith(token: token);
    }
  }

  UserEntity _mergeUser({
    required UserEntity primary,
    UserEntity? fallback,
    required String token,
  }) {
    return UserEntity(
      id: _bestString(primary.id, fallback?.id),
      email: _bestString(primary.email, fallback?.email),
      name: _bestString(primary.name, fallback?.name),
      phone: _bestNullableString(primary.phone, fallback?.phone),
      role: _bestNullableString(primary.role, fallback?.role),
      status: _bestNullableString(primary.status, fallback?.status),
      token: token,
      referralCode: _bestNullableString(
        primary.referralCode,
        fallback?.referralCode,
      ),
    );
  }

  String _bestString(String primary, String? fallback) {
    final normalizedPrimary = primary.trim();
    if (normalizedPrimary.isNotEmpty) return primary;

    final normalizedFallback = fallback?.trim();
    if (normalizedFallback != null && normalizedFallback.isNotEmpty) {
      return fallback!;
    }

    return '';
  }

  String? _bestNullableString(String? primary, String? fallback) {
    final normalizedPrimary = primary?.trim();
    if (normalizedPrimary != null && normalizedPrimary.isNotEmpty) {
      return primary;
    }

    final normalizedFallback = fallback?.trim();
    if (normalizedFallback != null && normalizedFallback.isNotEmpty) {
      return fallback;
    }

    return null;
  }

  bool _isChangedEmail(String? nextEmail, String? previousEmail) {
    final normalizedNext = nextEmail?.trim().toLowerCase();
    if (normalizedNext == null || normalizedNext.isEmpty) return false;

    final normalizedPrevious = previousEmail?.trim().toLowerCase();
    return normalizedNext != normalizedPrevious;
  }
}
