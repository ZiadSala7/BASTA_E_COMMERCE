import 'package:equatable/equatable.dart';

import 'user_entity.dart';

class ProfileUpdateResult extends Equatable {
  final UserEntity user;
  final String? message;
  final bool emailVerificationRequired;

  const ProfileUpdateResult({
    required this.user,
    this.message,
    this.emailVerificationRequired = false,
  });

  @override
  List<Object?> get props => [user, message, emailVerificationRequired];
}
