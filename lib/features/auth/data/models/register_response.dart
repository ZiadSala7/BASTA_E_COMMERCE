import 'user_model.dart';

class RegisterResponse {
  final UserModel user;
  final String message;

  const RegisterResponse({required this.user, required this.message});

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    final payload = _normalizePayload(json);

    return RegisterResponse(
      user: UserModel.fromJson(payload),
      message:
          json['message']?.toString() ??
          'User registered successfully. Please check your email.',
    );
  }

  static Map<String, dynamic> _normalizePayload(Map<String, dynamic> json) {
    final data = json['data'];
    if (data is Map<String, dynamic>) {
      final nestedUser = data['user'];
      if (nestedUser is Map<String, dynamic>) {
        return nestedUser;
      }

      if (nestedUser is Map) {
        return nestedUser.map((key, value) => MapEntry(key.toString(), value));
      }

      return data;
    }

    if (data is Map) {
      final normalizedData = data.map(
        (key, value) => MapEntry(key.toString(), value),
      );
      final nestedUser = normalizedData['user'];
      if (nestedUser is Map<String, dynamic>) {
        return nestedUser;
      }

      if (nestedUser is Map) {
        return nestedUser.map((key, value) => MapEntry(key.toString(), value));
      }

      return normalizedData;
    }

    return json;
  }
}
