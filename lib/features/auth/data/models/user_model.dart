import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    super.phone,
    super.role,
    super.status,
    super.token,
    super.referralCode,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final firstName = _nullableString(
      json['firstName'] ?? json['first_name'] ?? json['givenName'],
    );
    final lastName = _nullableString(
      json['lastName'] ?? json['last_name'] ?? json['familyName'],
    );
    final combinedName = [
      firstName,
      lastName,
    ].where((part) => part != null && part.trim().isNotEmpty).join(' ');

    return UserModel(
      id: _asString(json['id'] ?? json['_id']),
      email: _asString(json['email']),
      name: _asString(
        json['name'] ??
            json['fullName'] ??
            json['full_name'] ??
            json['displayName'] ??
            json['display_name'] ??
            json['username'] ??
            combinedName,
      ),
      phone: _nullableString(json['phone']),
      role: _nullableString(json['role']),
      status: _nullableString(json['status']),
      token: _nullableString(json['token']),
      referralCode: _nullableString(
        json['referralCode'] ??
            json['referral_code'] ??
            json['refCode'] ??
            json['ref_code'],
      ),
    );
  }

  factory UserModel.fromEntity(UserEntity user) {
    return UserModel(
      id: user.id,
      email: user.email,
      name: user.name,
      phone: user.phone,
      role: user.role,
      status: user.status,
      token: user.token,
      referralCode: user.referralCode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      if (phone != null) 'phone': phone,
      if (role != null) 'role': role,
      if (status != null) 'status': status,
      if (token != null) 'token': token,
      if (referralCode != null) 'referralCode': referralCode,
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
