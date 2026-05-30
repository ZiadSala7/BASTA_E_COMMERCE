enum AuthVerificationFlow { registration, emailConfirmation, passwordReset }

class AuthVerificationArgs {
  final AuthVerificationFlow flow;
  final String destination;
  final String? name;
  final String? email;
  final String? password;
  final String? phone;

  const AuthVerificationArgs.registration({
    required String this.name,
    required String this.email,
    required String this.password,
    this.phone,
  }) : flow = AuthVerificationFlow.registration,
       destination = email;

  const AuthVerificationArgs.emailConfirmation({required String this.email})
    : flow = AuthVerificationFlow.emailConfirmation,
      destination = email,
      name = null,
      password = null,
      phone = null;

  const AuthVerificationArgs.passwordReset({required this.destination})
    : flow = AuthVerificationFlow.passwordReset,
      name = null,
      email = null,
      password = null,
      phone = null;
}

class AuthPasswordResetArgs {
  final String token;

  const AuthPasswordResetArgs({required this.token});
}
