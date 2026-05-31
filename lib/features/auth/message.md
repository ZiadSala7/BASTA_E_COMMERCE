Here is the corrected and fully updated Markdown file. You can send this directly to your Flutter developer!

Markdown
# Auth Login, Register, and Verification Flow

This file documents how login, register, and email verification are implemented in the app, from the UI button click down to the API call and local session storage.

## Main Files

- `presentation/pages/login_page.dart`
- `presentation/pages/register_page.dart`
- `presentation/pages/verification_page.dart`
- `presentation/cubits/auth_cubit.dart`
- `domain/usecases/login_usecase.dart`
- `domain/usecases/register_usecase.dart`
- `domain/usecases/confirm_email_usecase.dart`
- `domain/repositories/auth_repository.dart`
- `data/repositories/auth_repository_impl.dart`
- `data/datasources/auth_remote_datasource.dart`
- `data/datasources/auth_local_datasource.dart`
- `data/models/login_request.dart`
- `data/models/login_response.dart`
- `data/models/register_request.dart`
- `data/models/register_response.dart`
- `core/api/endpoints.dart`
- `core/api/api_interceptors.dart`
- `core/di/service_locator.dart`

## Endpoints

Defined in `lib/core/api/endpoints.dart`:

```dart
static const String users = 'api/users';
static const String login = '$users/login';
static const String register = '$users/register';
static const String confirmEmail = '$users/confirm-email';
static const String resendConfirmation = '$users/resend-confirmation';
So the app calls:

POST api/users/login

POST api/users/register

POST api/users/confirm-email

POST api/users/resend-confirmation

Login Flow
1. User submits the login form
In login_page.dart, _submit() validates the form, then calls AuthCubit.login.

Dart
void _submit() {
  if (!_formKey.currentState!.validate()) return;

  context.read<AuthCubit>().login(
    _emailController.text.trim(),
    _passwordController.text,
    rememberSession: _rememberMe,
  );
}
2. AuthCubit starts loading and calls LoginUseCase
If the backend returns a 401 Unauthorized with a message stating the account is PENDING, the app routes the user to the verification screen.

3. Expected API Response
The backend returns a clean JSON structure. Token extraction is straightforward:

JSON
{
  "status": "success",
  "message": "Login successful",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVC...", 
  "data": {
    "user": {
      "id": "uuid",
      "name": "User Name",
      "email": "user@example.com",
      "role": "CUSTOMER",
      "status": "ACTIVE"
    }
  }
}
4. UI reacts to state
In login_page.dart, BlocConsumer listens for the cubit result:

Dart
if (state is AuthAuthenticated) {
  context.go(AppRoutes.mainNavigation);
}

if (state is AuthEmailConfirmationRequired) {
  context.push(
    AppRoutes.verification,
    extra: AuthVerificationArgs.emailConfirmation(email: state.email),
  );
}
Register Flow (UPDATED)
Important Rule: The backend creates new users with a PENDING status. They cannot log in immediately. They MUST verify their email with a 6-digit OTP first.

1. User submits the register form
In register_page.dart:

Dart
void _submit() {
  if (!_formKey.currentState!.validate()) return;

  context.read<AuthCubit>().register(
    _emailController.text.trim(),
    _passwordController.text,
    _nameController.text.trim(),
    _phoneController.text.trim(),
  );
}
2. AuthCubit calls register and navigates to Verification
In auth_cubit.dart, register creates the account. On a 201 Created success, it emits a pending state to route the user to the OTP screen. It no longer attempts to auto-login.

Dart
final registeredUser = await _registerUseCase(
  email: email,
  password: password,
  name: name,
  phone: phone,
  role: role,
);

emit(AuthRegistrationPending(
  registeredUser,
  message: "User registered successfully. Please check your email for the confirmation code.",
));
3. Expected API Response
The backend returns this structure for successful registration:

JSON
{
  "status": "success",
  "message": "User registered successfully",
  "data": {
    "id": "uuid",
    "name": "User Name",
    "email": "user@example.com",
    "role": "CUSTOMER"
  }
}
Email Confirmation Flow (NEW)
1. User submits OTP
On verification_page.dart, the user enters the 6-digit code received via email.

Dart
void _submitOtp(String otpCode) {
  context.read<AuthCubit>().confirmEmail(otpCode);
}
2. AuthRepository calls the API
The repository sends the token to the backend.

Dart
// Request Body
{
  "token": "123456" 
}
3. Handling Success
If the backend returns 200 OK, the user's status is updated to ACTIVE. The Cubit can now safely call _loginUseCase using the cached credentials to generate the JWT, or navigate the user to the LoginPage to sign in manually.

Short Summary
Login:

Plaintext
LoginPage
 -> AuthCubit.login
 -> LoginUseCase
 -> AuthRepository.login
 -> POST api/users/login
 -> Parse Token and User Data
 -> Save locally
 -> AuthAuthenticated -> Go to Home
Register & Verification:

Plaintext
RegisterPage
 -> AuthCubit.register
 -> POST api/users/register
 -> Returns 201 Created
 -> AuthRegistrationPending
 -> Navigate to VerificationPage
 
VerificationPage (User enters 6-digit OTP)
 -> AuthCubit.confirmEmail
 -> POST api/users/confirm-email
 -> Returns 200 OK
 -> User is now ACTIVE
 -> AuthCubit calls LoginUseCase (or user logs in manually)
 -> AuthAuthenticated -> Go to Home