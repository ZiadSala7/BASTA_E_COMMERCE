import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? token;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    this.token,
  });

  UserEntity copyWith({
    String? id,
    String? email,
    String? name,
    String? token,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      token: token ?? this.token,
    );
  }

  @override
  List<Object?> get props => [id, email, name, token];
}
