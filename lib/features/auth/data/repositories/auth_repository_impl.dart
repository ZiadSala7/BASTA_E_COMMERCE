import '../../../../core/auth/session_token_store.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/forgot_password_request.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final SessionTokenStore _sessionTokenStore;

  const AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required SessionTokenStore sessionTokenStore,
  }) : _remoteDataSource = remoteDataSource,
       _sessionTokenStore = sessionTokenStore;

  @override
  Future<UserEntity> login(
    String email,
    String password, {
    bool rememberSession = true,
  }) async {
    final loginResponse = await _remoteDataSource.login(
      LoginRequest(email: email, password: password),
    );

    await _sessionTokenStore.saveToken(
      loginResponse.token,
      persist: rememberSession,
    );

    return loginResponse.user.copyWith(token: loginResponse.token);
  }

  @override
  Future<UserEntity> register(
    String email,
    String password,
    String name,
    String phone,
  ) async {
    final loginResponse = await _remoteDataSource.register(
      RegisterRequest(
        email: email,
        password: password,
        name: name,
        phone: phone,
      ),
    );

    await _sessionTokenStore.saveToken(loginResponse.token);

    return loginResponse.user.copyWith(token: loginResponse.token);
  }

  @override
  Future<String> forgotPassword(String email) {
    return _remoteDataSource.forgotPassword(
      ForgotPasswordRequest(email: email),
    );
  }

  @override
  Future<UserEntity> getCurrentUser() async {
    final token = await _sessionTokenStore.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('No active session found.');
    }

    final user = await _remoteDataSource.getCurrentUser();
    return user.copyWith(token: token);
  }

  @override
  Future<void> logout() async {
    try {
      await _remoteDataSource.logout();
    } catch (_) {
      // Stateless JWT logout is satisfied once the local token is cleared.
    } finally {
      await _sessionTokenStore.clearToken();
    }
  }
}
