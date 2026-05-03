import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    super.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: _asString(json['id'] ?? json['_id']),
      email: _asString(json['email']),
      name: _asString(json['name'] ?? json['fullName'] ?? json['username']),
      token: _nullableString(json['token']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      if (token != null) 'token': token,
    };
  }

  static String _asString(dynamic value) {
    if (value == null) {
      return '';
    }

    return value.toString();
  }

  static String? _nullableString(dynamic value) {
    if (value == null) {
      return null;
    }

    final normalized = value.toString();
    return normalized.isEmpty ? null : normalized;
  }
}
