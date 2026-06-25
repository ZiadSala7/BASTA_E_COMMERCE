# Auth Login And Register Flow

This file documents how login and register are implemented in the app, from the UI button click down to the API call and local session storage.

## Main Files

- `presentation/pages/login_page.dart`
- `presentation/pages/register_page.dart`
- `presentation/cubits/auth_cubit.dart`
- `domain/usecases/login_usecase.dart`
- `domain/usecases/register_usecase.dart`
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
```

So the app calls:

- `POST api/users/login`
- `POST api/users/register`

## Dependency Injection

The app wires auth dependencies in `lib/core/di/service_locator.dart`.

```dart
getIt.registerLazySingleton<AuthRemoteDataSource>(
  () => AuthRemoteDataSourceImpl(dioConsumer: getIt()),
);

getIt.registerSingleton<AuthRepository>(
  AuthRepositoryImpl(remoteDataSource: getIt(), localDataSource: getIt()),
);

getIt.registerLazySingleton<LoginUseCase>(() => LoginUseCase(getIt()));
getIt.registerLazySingleton<RegisterUseCase>(() => RegisterUseCase(getIt()));

getIt.registerFactory<AuthCubit>(
  () => AuthCubit(
    loginUseCase: getIt(),
    registerUseCase: getIt(),
    // other auth use cases...
  ),
);
```

## Login Flow

### 1. User submits the login form

In `login_page.dart`, `_submit()` validates the form, then calls `AuthCubit.login`.

```dart
void _submit() {
  if (!_formKey.currentState!.validate()) {
    return;
  }

  context.read<AuthCubit>().login(
    _emailController.text.trim(),
    _passwordController.text,
    rememberSession: _rememberMe,
  );
}
```

### 2. AuthCubit starts loading and calls LoginUseCase

In `auth_cubit.dart`:

```dart
Future<void> login(
  String email,
  String password, {
  bool rememberSession = true,
}) async {
  emit(AuthLoading());
  try {
    final user = await _loginUseCase(
      email: email,
      password: password,
      rememberSession: rememberSession,
    );
    emit(AuthAuthenticated(user));
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

### 3. LoginUseCase calls the repository

In `login_usecase.dart`:

```dart
Future<UserEntity> call({
  required String email,
  required String password,
  bool rememberSession = true,
}) {
  return _repository.login(email, password, rememberSession: rememberSession);
}
```

### 4. Repository calls the API and saves session data

In `auth_repository_impl.dart`, login creates a `LoginRequest`, calls the remote datasource, then stores the token and user locally.

```dart
final loginResponse = await _remoteDataSource.login(
  LoginRequest(email: email, password: password),
);

final user = loginResponse.user.copyWith(token: loginResponse.token);

await _localDataSource.saveToken(
  loginResponse.token,
  persist: rememberSession,
);
await _localDataSource.saveUser(
  UserModel.fromEntity(user),
  persist: rememberSession,
);

return user;
```

### 5. Remote datasource sends the request

In `auth_remote_datasource.dart`:

```dart
final response = await _dioConsumer.post(
  Endpoints.login,
  data: request.toJson(),
);

return LoginResponse.fromJson(_asMap(response.data));
```

The request body comes from `login_request.dart`:

```dart
Map<String, dynamic> toJson() {
  return {'email': email, 'password': password};
}
```

### 6. Response parsing

In `login_response.dart`, the app supports token fields from different API shapes:

```dart
final token =
    json['token'] ??
    json['jwt'] ??
    json['accessToken'] ??
    payload['token'] ??
    payload['jwt'] ??
    payload['accessToken'] ??
    '';
```

Then it builds:

```dart
LoginResponse(
  user: UserModel.fromJson(userJson.isEmpty ? payload : userJson),
  token: token.toString(),
);
```

### 7. UI reacts to state

In `login_page.dart`, `BlocConsumer` listens for the cubit result:

```dart
if (state is AuthAuthenticated) {
  context.go(AppRoutes.mainNavigation);
}

if (state is AuthEmailConfirmationRequired) {
  context.push(
    AppRoutes.verification,
    extra: AuthVerificationArgs.emailConfirmation(email: state.email),
  );
}

if (state is AuthError) {
  ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(state.message)));
}
```

## Register Flow

### 1. User submits the register form

In `register_page.dart`:

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

### 2. AuthCubit calls register, then opens verification

In `auth_cubit.dart`, register creates the account. The backend creates new users as `PENDING`, so the app emits a pending state and sends the user to the OTP screen instead of trying to log in immediately.

```dart
registeredUser = await _registerUseCase(
  email: email,
  password: password,
  name: name,
  phone: phone,
  role: role,
);

emit(
  AuthRegistrationPending(
    registeredUser,
    message:
        'User registered successfully. Please check your email for the confirmation code.',
  ),
);
```

If login later fails because the account is still pending, the cubit emits a verification state:

```dart
if (_isEmailConfirmationRequired(message)) {
  emit(AuthEmailConfirmationRequired(email: email, message: message));
  return;
}
```

### 3. RegisterUseCase calls the repository

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

### 4. Repository builds RegisterRequest

In `auth_repository_impl.dart`:

```dart
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
```

### 5. Register request body

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

Default role is:

```dart
this.role = 'CUSTOMER'
```

### 6. Remote datasource sends register request

In `auth_remote_datasource.dart`:

```dart
final response = await _dioConsumer.post(
  Endpoints.register,
  data: request.toJson(),
);

return RegisterResponse.fromJson(_asMap(response.data));
```

### 7. Register response parsing

In `register_response.dart`, the app supports these response shapes:

- user data directly in response body
- user data inside `data`
- user data inside `data.user`

```dart
final payload = _normalizePayload(json);

return RegisterResponse(
  user: UserModel.fromJson(payload),
  message:
      json['message']?.toString() ??
      'User registered successfully. Please check your email.',
);
```

### 8. UI reacts to register state

In `register_page.dart`:

```dart
if (state is AuthAuthenticated) {
  context.go(AppRoutes.mainNavigation);
}

if (state is AuthRegistrationPending) {
  context.push(
    AppRoutes.verification,
    extra: AuthVerificationArgs.registration(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      phone: _phoneController.text.trim(),
    ),
  );
}

if (state is AuthError) {
  ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(state.message)));
}
```

## Token Usage After Login

After login, the token is saved through `AuthLocalDataSource`. API requests then include it automatically through `ApiInterceptors`.

In `api_interceptors.dart`:

```dart
final token = await sl<SessionTokenStore>().getToken();
if (token != null && token.isNotEmpty) {
  options.headers['Authorization'] = 'Bearer $token';
}
```

So any authorized request after login automatically sends:

```http
Authorization: Bearer USER_TOKEN
```

If an API call returns `401`, the interceptor clears the local token:

```dart
if (err.response?.statusCode == 401) {
  await sl<SessionTokenStore>().clearToken();
}
```

## Short Summary

Login:

```text
LoginPage
 -> AuthCubit.login
 -> LoginUseCase
 -> AuthRepository.login
 -> AuthRemoteDataSource.login
 -> POST api/users/login
 -> LoginResponse
 -> save token and user locally
 -> AuthAuthenticated
 -> navigate to main app
```

Register:

```text
RegisterPage
 -> AuthCubit.register
 -> RegisterUseCase
 -> AuthRepository.register
 -> AuthRemoteDataSource.register
 -> POST api/users/register
 -> RegisterResponse
 -> AuthRegistrationPending
 -> VerificationPage
 -> POST api/users/confirm-email
 -> AuthCubit tries LoginUseCase with cached registration credentials
 -> save token and user locally
 -> AuthAuthenticated
```
