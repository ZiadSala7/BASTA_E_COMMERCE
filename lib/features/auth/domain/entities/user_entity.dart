import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final String? role;
  final String? status;
  final String? token;
  final String? referralCode;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.role,
    this.status,
    this.token,
    this.referralCode,
  });

  UserEntity copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    String? role,
    String? status,
    String? token,
    String? referralCode,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      status: status ?? this.status,
      token: token ?? this.token,
      referralCode: referralCode ?? this.referralCode,
    );
  }

  @override
  List<Object?> get props => [
    id,
    email,
    name,
    phone,
    role,
    status,
    token,
    referralCode,
  ];
}
