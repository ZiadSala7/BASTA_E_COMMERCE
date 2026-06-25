# Register Flow

This file explains how the Flutter register process works in this app, from the register screen to the backend request, email verification, and final login.

## Main Files

- `lib/features/auth/presentation/pages/register_page.dart`
- `lib/features/auth/presentation/cubits/auth_cubit.dart`
- `lib/features/auth/presentation/cubits/auth_state.dart`
- `lib/features/auth/domain/usecases/register_usecase.dart`
- `lib/features/auth/domain/repositories/auth_repository.dart`
- `lib/features/auth/data/repositories/auth_repository_impl.dart`
- `lib/features/auth/data/datasources/auth_remote_datasource.dart`
- `lib/features/auth/data/models/register_request.dart`
- `lib/features/auth/data/models/register_response.dart`
- `lib/features/auth/presentation/pages/verification_page.dart`
- `lib/features/auth/presentation/models/auth_verification_args.dart`
- `lib/core/api/endpoints.dart`
- `lib/core/di/service_locator.dart`

## Short Summary

The user fills the register form with name, phone, email, password, and confirm password. The page validates the input locally. If the form is valid, it calls `AuthCubit.register(...)`.

The cubit sends the data to the register use case, which calls the repository, which calls the remote datasource. The datasource sends a `POST` request to:

```text
api/users/register
```

After the account is created, the cubit asks the backend to send or resend the email confirmation code. The UI then opens the verification page. When the user enters the 6 digit code, the app confirms the email, then automatically logs in with the same email and password and navigates to the main app.

## Dependency Setup

The auth objects are wired in `lib/core/di/service_locator.dart`.

```dart
getIt.registerLazySingleton<AuthRemoteDataSource>(
  () => AuthRemoteDataSourceImpl(dioConsumer: getIt()),
);

getIt.registerSingleton<AuthRepository>(
  AuthRepositoryImpl(
    remoteDataSource: getIt(),
    localDataSource: getIt(),
    firebaseSocialAuthDataSource: getIt(),
  ),
);

getIt.registerLazySingleton<RegisterUseCase>(
  () => RegisterUseCase(getIt()),
);

getIt.registerFactory<AuthCubit>(
  () => AuthCubit(
    registerUseCase: getIt(),
    confirmEmailUseCase: getIt(),
    resendConfirmationUseCase: getIt(),
    loginUseCase: getIt(),
    // other auth use cases...
  ),
);
```

The register page receives its own `AuthCubit` from the router:

```dart
GoRoute(
  path: AppRoutes.register,
  builder: (context, state) => BlocProvider(
    create: (_) => sl<AuthCubit>(),
    child: const RegisterPage(),
  ),
),
```

## Step 1: User Submits The Form

In `register_page.dart`, the submit button calls `_submit`.

```dart
void _submit() {
  if (!_formKey.currentState!.validate()) {
    return;
  }

  context.read<AuthCubit>().register(
    _emailController.text.trim(),
    _passwordController.text,
    _nameController.text.trim(),
    _phoneController.text.trim(),
  );
}
```

The important part is that Flutter does not call the API until the form validators pass.

## Step 2: Local Validation

The form uses `AuthValidators`:

```dart
AuthValidators.name(value, localizations)
AuthValidators.phone(value, localizations)
AuthValidators.email(value, localizations)
AuthValidators.password(value, localizations)
AuthValidators.confirmPassword(
  value,
  _passwordController.text,
  localizations,
)
```

Validation rules:

- Name is required.
- Email is required and must match a simple email pattern.
- Phone is optional, but if entered it must match `+?[0-9]{8,15}`.
- Password is required and must be at least 8 characters.
- Confirm password is required and must equal the password.

## Step 3: AuthCubit Starts Register

In `auth_cubit.dart`, the register method starts by emitting `AuthLoading`.

```dart
Future<void> register(
  String email,
  String password,
  String name,
  String phone, {
  String role = 'CUSTOMER',
}) async {
  emit(AuthLoading());
  try {
    final registeredUser = await _registerUseCase(
      email: email,
      password: password,
      name: name,
      phone: phone,
      role: role,
    );

    final confirmationMessage = await _requestConfirmationCode(email);
    emit(
      AuthRegistrationPending(registeredUser, message: confirmationMessage),
    );
  } catch (e) {
    final message = _mapErrorMessage(e);
    if (_isEmailConfirmationRequired(message)) {
      emit(AuthEmailConfirmationRequired(email: email, message: message));
      return;
    }

    emit(AuthError(message));
  }
}
```

What happens here:

- `AuthLoading` makes the register button show loading.
- `_registerUseCase(...)` creates the account through the domain/data layers.
- `_requestConfirmationCode(email)` calls resend confirmation so the user receives the OTP/code.
- `AuthRegistrationPending` tells the UI that the account exists but still needs email verification.
- If the backend says the email needs confirmation, the cubit emits `AuthEmailConfirmationRequired`.
- Any other failure becomes `AuthError`.

## Step 4: RegisterUseCase Calls The Repository

In `register_usecase.dart`:

```dart
Future<UserEntity> call({
  required String email,
  required String password,
  required String name,
  required String phone,
  String role = 'CUSTOMER',
}) {
  return _repository.register(email, password, name, phone, role);
}
```

The use case does not transform the data. It keeps the presentation layer separated from the data layer.

## Step 5: Repository Builds The Request Model

In `auth_repository_impl.dart`:

```dart
Future<UserEntity> register(
  String email,
  String password,
  String name,
  String phone,
  String role,
) async {
  final registerResponse = await _remoteDataSource.register(
    RegisterRequest(
      email: email,
      password: password,
      name: name,
      phone: phone,
      role: role,
    ),
  );

  return registerResponse.user;
}
```

Unlike login, register does not save a token locally here. The user must verify the email first. The session is saved later after automatic login.

## Step 6: Request Body Sent To Backend

In `register_request.dart`:

```dart
Map<String, dynamic> toJson() {
  return {
    'email': email,
    'password': password,
    'name': name,
    if (phone.trim().isNotEmpty) 'phone': phone,
    'role': role,
  };
}
```

Default customer register request:

```json
{
  "email": "customer@example.com",
  "password": "password123",
  "name": "Customer Name",
  "phone": "+201234567890"
}
```

Notes:

- `phone` is only sent if it is not empty.
- `role` defaults to `CUSTOMER` and is sent in the register request, matching the Postman collection.

## Step 7: Remote Datasource Sends The API Call

In `auth_remote_datasource.dart`:

```dart
Future<RegisterResponse> register(RegisterRequest request) async {
  try {
    final response = await _dioConsumer.post(
      Endpoints.register,
      data: request.toJson(),
    );

    return RegisterResponse.fromJson(_asMap(response.data));
  } on DioException catch (error, stackTrace) {
    log(
      'Register request failed: ${_messageFromDio(error)}',
      error: error,
      stackTrace: stackTrace,
    );
    throw Exception(_messageFromDio(error));
  }
}
```

The endpoint is defined in `lib/core/api/endpoints.dart`:

```dart
static const String users = 'api/users';
static const String register = '$users/register';
static const String resendConfirmation = '$users/resend-confirmation';
static const String confirmEmail = '$users/confirm-email';
```

So the actual register path is:

```text
POST api/users/register
```

The full URL is `ApiKeys.baseUrl + api/users/register`, because `DioHelper` sets the Dio base URL from `ApiKeys.baseUrl`.

## Step 8: Register Response Parsing

In `register_response.dart`, the app accepts more than one backend response shape.

```dart
factory RegisterResponse.fromJson(Map<String, dynamic> json) {
  final payload = _normalizePayload(json);

  return RegisterResponse(
    user: UserModel.fromJson(payload),
    message:
        json['message']?.toString() ??
        'User registered successfully. Please check your email.',
  );
}
```

Supported response payload styles include:

```json
{
  "message": "User registered successfully",
  "data": {
    "user": {
      "id": "123",
      "email": "customer@example.com",
      "name": "Customer Name",
      "role": "CUSTOMER",
      "status": "PENDING"
    }
  }
}
```

Or:

```json
{
  "message": "User registered successfully",
  "data": {
    "id": "123",
    "email": "customer@example.com",
    "name": "Customer Name",
    "role": "CUSTOMER",
    "status": "PENDING"
  }
}
```

Or a direct user object at the response root.

## Step 9: The UI Opens Verification

Back in `register_page.dart`, `BlocConsumer` listens for `AuthRegistrationPending`.

```dart
if (state is AuthRegistrationPending) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        state.message ?? 'Check your email for the verification code.',
      ),
    ),
  );
  context.push(w
    AppRoutes.verification,
    extra: AuthVerificationArgs.registration(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      phone: _phoneController.text.trim(),
    ),
  );
}
```

The app passes registration arguments to the verification screen:

```dart
const AuthVerificationArgs.registration({
  required String this.name,
  required String this.email,
  required String this.password,
  this.phone,
}) : flow = AuthVerificationFlow.registration,
     destination = email;
```

The password is passed only in memory through route arguments. It is used after email confirmation to automatically log the user in.

## Step 10: User Enters The Verification Code

In `verification_page.dart`, the user must enter a 6 digit code.

```dart
void _submit() {
  final localizations = AppLocalizations.of(context)!;
  final codeError = AuthValidators.verificationCode(_code, localizations);

  if (codeError != null) {
    setState(() {
      _errorText = codeError;
    });
    return;
  }

  setState(() {
    _errorText = null;
  });

  if (widget.arguments.flow == AuthVerificationFlow.passwordReset) {
    context.push(
      AppRoutes.resetPassword,
      extra: AuthPasswordResetArgs(token: _code),
    );
    return;
  }

  context.read<AuthCubit>().confirmEmail(_code);
}
```

For registration, the verification page calls:

```dart
context.read<AuthCubit>().confirmEmail(_code);
```

The backend call is:

```text
POST api/users/confirm-email
```

With this body:

```json
{
  "token": "123456"
}
```

## Step 11: After Confirmation, The App Logs In

When email confirmation succeeds, the cubit emits `AuthEmailConfirmed`. The verification page listens for that state.

```dart
if (state is AuthEmailConfirmed) {
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(state.message)));

  if (widget.arguments.flow == AuthVerificationFlow.registration &&
      widget.arguments.email != null &&
      widget.arguments.password != null) {
    context.read<AuthCubit>().login(
      widget.arguments.email!,
      widget.arguments.password!,
      rememberSession: true,
    );
    return;
  }

  context.go(AppRoutes.login);
}
```

For registration flow:

1. Email is confirmed.
2. The same cubit calls `login(email, password)`.
3. Login saves the token and user locally.
4. The cubit emits `AuthAuthenticated`.
5. The verification page navigates to the main navigation page.

```dart
if (state is AuthAuthenticated) {
  context.go(AppRoutes.mainNavigation);
}
```

## Resend Code Flow

During registration, the verification page can resend the confirmation code.

```dart
void _resendCode() {
  if (!_canResendCode || _remainingSeconds > 0) {
    return;
  }

  final email = widget.arguments.email;
  if (email == null || email.isEmpty) {
    return;
  }

  context.read<AuthCubit>().resendConfirmation(email);
}
```

The backend call is:

```text
POST api/users/resend-confirmation
```

With this body:

```json
{
  "email": "customer@example.com"
}
```

The resend button has a 20 second cooldown.

## States Used In Register

These auth states are important for register:

- `AuthInitial`: default state before anything happens.
- `AuthLoading`: register, confirm, resend, or login is running.
- `AuthRegistrationPending`: register succeeded and verification is required.
- `AuthEmailConfirmationRequired`: backend says the account already exists but needs verification.
- `AuthEmailConfirmed`: verification code was accepted.
- `AuthAuthenticated`: user is logged in after verification.
- `AuthError`: something failed and the UI shows a snackbar.

## Complete Register Sequence

```text
RegisterPage
 -> _submit()
 -> form validators
 -> AuthCubit.register(email, password, name, phone)
 -> AuthLoading
 -> RegisterUseCase.call(...)
 -> AuthRepository.register(...)
 -> AuthRepositoryImpl.register(...)
 -> RegisterRequest.toJson()
 -> AuthRemoteDataSource.register(...)
 -> DioConsumer.post(Endpoints.register)
 -> POST api/users/register
 -> RegisterResponse.fromJson(...)
 -> UserModel.fromJson(...)
 -> AuthCubit._requestConfirmationCode(email)
 -> POST api/users/resend-confirmation
 -> AuthRegistrationPending
 -> RegisterPage listener
 -> context.push(AppRoutes.verification, AuthVerificationArgs.registration(...))
 -> VerificationPage
 -> user enters 6 digit code
 -> AuthCubit.confirmEmail(code)
 -> POST api/users/confirm-email
 -> AuthEmailConfirmed
 -> VerificationPage calls AuthCubit.login(email, password)
 -> POST api/users/login
 -> token and user are saved locally
 -> AuthAuthenticated
 -> context.go(AppRoutes.mainNavigation)
```

## Error Handling

API errors are normalized in `AuthRemoteDataSourceImpl._messageFromDio`.

The datasource tries to read errors in this order:

1. `message`
2. first item in `errors` list
3. first value in `errors` map
4. `error`
5. timeout messages
6. connection error message
7. Dio's fallback error message

The cubit removes the `Exception: ` prefix before showing the message:

```dart
String _mapErrorMessage(Object error) {
  const exceptionPrefix = 'Exception: ';
  final message = error.toString().trim();
  if (message.startsWith(exceptionPrefix)) {
    return message.substring(exceptionPrefix.length);
  }
  return message;
}
```

Then the UI displays the final message with a snackbar.

## Important Notes

- Registration itself does not create a local logged-in session.
- The app verifies the email first, then logs in automatically.
- The verification page needs the registration email and password so it can log in after confirmation.
- `phone` is optional at the request level.
- `role` defaults to `CUSTOMER` and is sent with the register request.
- The register flow depends on three backend endpoints: register, resend confirmation, and confirm email.
