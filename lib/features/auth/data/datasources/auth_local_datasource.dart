import 'dart:convert';

import '../../../../core/auth/session_token_store.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource implements SessionTokenStore {
  Future<void> saveUser(UserModel user, {bool persist = true});
  Future<UserModel?> getUser();
  Future<void> clearUser();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const _jwtTokenKey = 'jwt_token';
  static const _currentUserKey = 'current_user';

  final SecureStorageService _secureStorageService;
  String? _inMemoryToken;
  UserModel? _inMemoryUser;

  AuthLocalDataSourceImpl({required SecureStorageService secureStorageService})
    : _secureStorageService = secureStorageService;

  @override
  Future<void> saveToken(String token, {bool persist = true}) async {
    _inMemoryToken = token;

    if (persist) {
      try {
        await _secureStorageService.writeString(
          key: _jwtTokenKey,
          value: token,
        );
      } catch (_) {
        // Keep the in-memory session alive even if secure storage is unavailable.
      }
      return;
    }

    try {
      await _secureStorageService.delete(_jwtTokenKey);
    } catch (_) {
      // The in-memory token above is enough for the current app session.
    }
  }

  @override
  Future<void> saveUser(UserModel user, {bool persist = true}) async {
    _inMemoryUser = user;

    if (persist) {
      try {
        await _secureStorageService.writeString(
          key: _currentUserKey,
          value: jsonEncode(user.toJson()),
        );
      } catch (_) {
        // Keep the in-memory user available even if secure storage is unavailable.
      }
      return;
    }

    try {
      await _secureStorageService.delete(_currentUserKey);
    } catch (_) {}
  }

  @override
  Future<String?> getToken() async {
    if (_inMemoryToken != null && _inMemoryToken!.isNotEmpty) {
      return _inMemoryToken;
    }

    try {
      _inMemoryToken = await _secureStorageService.readString(_jwtTokenKey);
    } catch (_) {
      _inMemoryToken = null;
    }
    return _inMemoryToken;
  }

  @override
  Future<UserModel?> getUser() async {
    if (_inMemoryUser != null) return _inMemoryUser;

    try {
      final storedUser = await _secureStorageService.readString(
        _currentUserKey,
      );
      if (storedUser == null || storedUser.isEmpty) return null;

      final decoded = jsonDecode(storedUser);
      if (decoded is Map<String, dynamic>) {
        _inMemoryUser = UserModel.fromJson(decoded);
      } else if (decoded is Map) {
        _inMemoryUser = UserModel.fromJson(
          decoded.map((key, value) => MapEntry(key.toString(), value)),
        );
      }
    } catch (_) {
      _inMemoryUser = null;
    }

    return _inMemoryUser;
  }

  @override
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<void> clearToken() async {
    _inMemoryToken = null;
    try {
      await _secureStorageService.delete(_jwtTokenKey);
    } catch (_) {}
  }

  @override
  Future<void> clearUser() async {
    _inMemoryUser = null;
    try {
      await _secureStorageService.delete(_currentUserKey);
    } catch (_) {}
  }
}
