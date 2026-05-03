import 'user_model.dart';

class LoginResponse {
  final UserModel user;
  final String token;

  const LoginResponse({required this.user, required this.token});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final payload = _normalizePayload(json);
    final userJson = _asMap(payload['user']);
    final token =
        payload['token'] ?? payload['jwt'] ?? payload['accessToken'] ?? '';

    return LoginResponse(
      user: UserModel.fromJson(userJson.isEmpty ? payload : userJson),
      token: token.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'user': user.toJson(), 'token': token};
  }

  static Map<String, dynamic> _normalizePayload(Map<String, dynamic> json) {
    final data = json['data'];
    final dataMap = _asMap(data);
    if (dataMap.isNotEmpty) {
      return dataMap;
    }

    return json;
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return value.map(
        (key, item) => MapEntry(key.toString(), item),
      );
    }

    return <String, dynamic>{};
  }
}
