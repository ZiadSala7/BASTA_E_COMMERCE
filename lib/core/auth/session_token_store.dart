abstract class SessionTokenStore {
  Future<void> saveToken(String token, {bool persist = true});
  Future<String?> getToken();
  Future<bool> hasToken();
  Future<void> clearToken();
}
