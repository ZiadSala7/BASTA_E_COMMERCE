part of '../auth_local_datasource.dart';

abstract class AuthLocalDataSource implements SessionTokenStore {
  Future<void> saveUser(UserModel user, {bool persist = true});
  Future<UserModel?> getUser();
  Future<void> clearUser();
}
