import 'user_model.dart';

class ProfileUpdateResponse {
  final UserModel user;
  final String? message;

  const ProfileUpdateResponse({required this.user, this.message});

  bool get requiresEmailVerification {
    final normalized = message?.toLowerCase() ?? '';
    return normalized.contains('verify') ||
        normalized.contains('verification') ||
        normalized.contains('pending');
  }

  factory ProfileUpdateResponse.fromJson(Map<String, dynamic> json) {
    final data = _asMap(json['data']);
    final userJson = _extractUserPayload(json);
    final message = _messageFrom(json, data);

    return ProfileUpdateResponse(
      user: UserModel.fromJson(userJson),
      message: message,
    );
  }

  static Map<String, dynamic> _extractUserPayload(Map<String, dynamic> json) {
    final directUser = _asMap(json['user']);
    if (directUser.isNotEmpty) return directUser;

    final data = _asMap(json['data']);
    final nestedUser = _asMap(data['user']);
    if (nestedUser.isNotEmpty) return nestedUser;
    if (data.isNotEmpty) return data;

    return json;
  }

  static String? _messageFrom(
    Map<String, dynamic> json,
    Map<String, dynamic> data,
  ) {
    final directMessage = json['message']?.toString();
    if (directMessage != null && directMessage.trim().isNotEmpty) {
      return directMessage;
    }

    final nestedMessage = data['message']?.toString();
    if (nestedMessage != null && nestedMessage.trim().isNotEmpty) {
      return nestedMessage;
    }

    return null;
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;

    if (value is Map) {
      return value.map((key, item) => MapEntry(key.toString(), item));
    }

    return <String, dynamic>{};
  }
}
