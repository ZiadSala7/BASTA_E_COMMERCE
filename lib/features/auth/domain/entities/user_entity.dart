class UserEntity {
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

  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      token: json['token'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'email': email, 'name': name, 'token': token};
  }

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
}
