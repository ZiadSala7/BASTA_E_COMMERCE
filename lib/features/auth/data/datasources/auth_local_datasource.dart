import '../../../../core/auth/session_token_store.dart';
import '../../../../core/storage/secure_storage_service.dart';

abstract class AuthLocalDataSource implements SessionTokenStore {}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const _jwtTokenKey = 'jwt_token';

  final SecureStorageService _secureStorageService;
  String? _inMemoryToken;

  AuthLocalDataSourceImpl({
    required SecureStorageService secureStorageService,
  }) : _secureStorageService = secureStorageService;

  @override
  Future<void> saveToken(String token, {bool persist = true}) async {
    _inMemoryToken = token;

    if (persist) {
      await _secureStorageService.writeString(
        key: _jwtTokenKey,
        value: token,
      );
      return;
    }

    await _secureStorageService.delete(_jwtTokenKey);
  }

  @override
  Future<String?> getToken() async {
    if (_inMemoryToken != null && _inMemoryToken!.isNotEmpty) {
      return _inMemoryToken;
    }

    _inMemoryToken = await _secureStorageService.readString(_jwtTokenKey);
    return _inMemoryToken;
  }

  @override
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<void> clearToken() async {
    _inMemoryToken = null;
    await _secureStorageService.delete(_jwtTokenKey);
  }
}
