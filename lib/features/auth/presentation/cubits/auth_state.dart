part of 'auth_cubit.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserEntity user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthRegistrationPending extends AuthState {
  final UserEntity user;
  final String? message;

  const AuthRegistrationPending(this.user, {this.message});

  @override
  List<Object?> get props => [user, message];
}

class AuthEmailConfirmationRequired extends AuthState {
  final String email;
  final String message;

  const AuthEmailConfirmationRequired({
    required this.email,
    required this.message,
  });

  @override
  List<Object?> get props => [email, message];
}

class AuthUnauthenticated extends AuthState {
  final String? message;

  const AuthUnauthenticated({this.message});

  @override
  List<Object?> get props => [message];
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthPasswordResetEmailSent extends AuthState {
  final String message;

  const AuthPasswordResetEmailSent(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthEmailConfirmed extends AuthState {
  final String message;

  const AuthEmailConfirmed(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthConfirmationCodeSent extends AuthState {
  final String message;

  const AuthConfirmationCodeSent(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthPasswordReset extends AuthState {
  final String message;

  const AuthPasswordReset(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthPasswordChanged extends AuthState {
  final String message;

  const AuthPasswordChanged(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthProfileUpdated extends AuthState {
  final UserEntity user;

  const AuthProfileUpdated(this.user);

  @override
  List<Object?> get props => [user];
}
