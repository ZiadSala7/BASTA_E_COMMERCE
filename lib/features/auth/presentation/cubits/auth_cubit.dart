import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/forgot_password_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final ForgotPasswordUseCase _forgotPasswordUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final LogoutUseCase _logoutUseCase;

  AuthCubit({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required ForgotPasswordUseCase forgotPasswordUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required LogoutUseCase logoutUseCase,
  }) : _loginUseCase = loginUseCase,
       _registerUseCase = registerUseCase,
       _forgotPasswordUseCase = forgotPasswordUseCase,
       _getCurrentUserUseCase = getCurrentUserUseCase,
       _logoutUseCase = logoutUseCase,
       super(AuthInitial());

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
      emit(AuthError(_mapErrorMessage(e)));
    }
  }

  Future<void> register(
    String email,
    String password,
    String name,
    String phone,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _registerUseCase(
        email: email,
        password: password,
        name: name,
        phone: phone,
      );
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(_mapErrorMessage(e)));
    }
  }

  Future<void> forgotPassword(String email) async {
    emit(AuthLoading());
    try {
      final message = await _forgotPasswordUseCase(email: email);
      emit(AuthPasswordResetEmailSent(message));
    } catch (e) {
      emit(AuthError(_mapErrorMessage(e)));
    }
  }

  Future<void> getCurrentUser() async {
    emit(AuthLoading());
    try {
      final user = await _getCurrentUserUseCase();
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthUnauthenticated(message: _mapErrorMessage(e)));
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());
    try {
      await _logoutUseCase();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(_mapErrorMessage(e)));
    }
  }

  String _mapErrorMessage(Object error) {
    const exceptionPrefix = 'Exception: ';
    final message = error.toString().trim();
    if (message.startsWith(exceptionPrefix)) {
      return message.substring(exceptionPrefix.length);
    }
    return message;
  }
}
