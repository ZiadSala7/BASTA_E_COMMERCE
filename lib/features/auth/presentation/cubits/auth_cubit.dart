import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/change_password_usecase.dart';
import '../../domain/usecases/confirm_email_usecase.dart';
import '../../domain/usecases/forgot_password_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/google_social_login_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/resend_confirmation_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase _loginUseCase;
  final GoogleSocialLoginUseCase _googleSocialLoginUseCase;
  final RegisterUseCase _registerUseCase;
  final ConfirmEmailUseCase _confirmEmailUseCase;
  final ResendConfirmationUseCase _resendConfirmationUseCase;
  final ForgotPasswordUseCase _forgotPasswordUseCase;
  final ResetPasswordUseCase _resetPasswordUseCase;
  final ChangePasswordUseCase _changePasswordUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final LogoutUseCase _logoutUseCase;

  AuthCubit({
    required LoginUseCase loginUseCase,
    required GoogleSocialLoginUseCase googleSocialLoginUseCase,
    required RegisterUseCase registerUseCase,
    required ConfirmEmailUseCase confirmEmailUseCase,
    required ResendConfirmationUseCase resendConfirmationUseCase,
    required ForgotPasswordUseCase forgotPasswordUseCase,
    required ResetPasswordUseCase resetPasswordUseCase,
    required ChangePasswordUseCase changePasswordUseCase,
    required UpdateProfileUseCase updateProfileUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required LogoutUseCase logoutUseCase,
  }) : _loginUseCase = loginUseCase,
       _googleSocialLoginUseCase = googleSocialLoginUseCase,
       _registerUseCase = registerUseCase,
       _confirmEmailUseCase = confirmEmailUseCase,
       _resendConfirmationUseCase = resendConfirmationUseCase,
       _forgotPasswordUseCase = forgotPasswordUseCase,
       _resetPasswordUseCase = resetPasswordUseCase,
       _changePasswordUseCase = changePasswordUseCase,
       _updateProfileUseCase = updateProfileUseCase,
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
      if (isClosed) return;
      emit(AuthAuthenticated(user));
    } catch (e) {
      if (isClosed) return;
      final message = _mapErrorMessage(e);
      if (_isEmailConfirmationRequired(message)) {
        emit(AuthEmailConfirmationRequired(email: email, message: message));
        return;
      }

      emit(AuthError(message));
    }
  }

  Future<void> loginWithGoogle({bool rememberSession = true}) async {
    emit(AuthLoading());
    try {
      final user = await _googleSocialLoginUseCase(
        rememberSession: rememberSession,
      );
      if (isClosed) return;
      emit(AuthAuthenticated(user));
    } catch (e) {
      if (isClosed) return;
      emit(AuthError(_mapErrorMessage(e)));
    }
  }

  Future<void> register(
    String email,
    String password,
    String name,
    String phone, {
    String role = 'CUSTOMER',
    String? couponCode,
    String? referralCode,
  }) async {
    emit(AuthLoading());
    try {
      final registeredUser = await _registerUseCase(
        email: email,
        password: password,
        name: name,
        phone: phone,
        role: role,
        couponCode: couponCode,
        referralCode: referralCode,
      );

      final confirmationMessage = await _requestConfirmationCode(email);
      if (isClosed) return;
      emit(
        AuthRegistrationPending(registeredUser, message: confirmationMessage),
      );
    } catch (e) {
      if (isClosed) return;
      final message = _mapErrorMessage(e);
      if (_isEmailConfirmationRequired(message)) {
        emit(AuthEmailConfirmationRequired(email: email, message: message));
        return;
      }

      emit(AuthError(message));
    }
  }

  Future<void> confirmEmail(String token) async {
    emit(AuthLoading());
    try {
      final message = await _confirmEmailUseCase(token: token);
      if (isClosed) return;
      emit(AuthEmailConfirmed(message));
    } catch (e) {
      if (isClosed) return;
      emit(AuthError(_mapErrorMessage(e)));
    }
  }

  Future<void> resendConfirmation(String email) async {
    emit(AuthLoading());
    try {
      final message = await _resendConfirmationUseCase(email: email);
      if (isClosed) return;
      emit(AuthConfirmationCodeSent(message));
    } catch (e) {
      if (isClosed) return;
      emit(AuthError(_mapErrorMessage(e)));
    }
  }

  Future<void> forgotPassword(String email) async {
    emit(AuthLoading());
    try {
      final message = await _forgotPasswordUseCase(email: email);
      if (isClosed) return;
      emit(AuthPasswordResetEmailSent(message));
    } catch (e) {
      if (isClosed) return;
      emit(AuthError(_mapErrorMessage(e)));
    }
  }

  Future<void> resetPassword(String token, String newPassword) async {
    emit(AuthLoading());
    try {
      final message = await _resetPasswordUseCase(
        token: token,
        newPassword: newPassword,
      );
      if (isClosed) return;
      emit(AuthPasswordReset(message));
    } catch (e) {
      if (isClosed) return;
      emit(AuthError(_mapErrorMessage(e)));
    }
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    emit(AuthLoading());
    try {
      final message = await _changePasswordUseCase(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      if (isClosed) return;
      emit(AuthPasswordChanged(message));
    } catch (e) {
      if (isClosed) return;
      emit(AuthError(_mapErrorMessage(e)));
    }
  }

  Future<void> updateProfile({
    String? name,
    String? phone,
    String? email,
  }) async {
    emit(AuthLoading());
    try {
      final user = await _updateProfileUseCase(
        name: name,
        phone: phone,
        email: email,
      );
      if (isClosed) return;
      if (user.emailVerificationRequired) {
        emit(
          AuthProfileEmailVerificationRequired(
            email: user.user.email,
            message:
                user.message ??
                'Profile updated. Please verify your new email before logging in again.',
          ),
        );
        return;
      }

      emit(AuthProfileUpdated(user.user));
    } catch (e) {
      if (isClosed) return;
      emit(AuthError(_mapErrorMessage(e)));
    }
  }

  Future<void> getCurrentUser() async {
    emit(AuthLoading());
    try {
      final user = await _getCurrentUserUseCase();
      if (isClosed) return;
      emit(AuthAuthenticated(user));
    } catch (e) {
      if (isClosed) return;
      emit(AuthUnauthenticated(message: _mapErrorMessage(e)));
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());
    try {
      await _logoutUseCase();
      if (isClosed) return;
      emit(const AuthUnauthenticated());
    } catch (e) {
      if (isClosed) return;
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

  bool _isEmailConfirmationRequired(String message) {
    final normalized = message.toLowerCase();
    final mentionsEmail = normalized.contains('email');
    final asksForConfirmation =
        normalized.contains('confirm') ||
        normalized.contains('verify') ||
        normalized.contains('verification');
    final isPendingAccount =
        normalized.contains('pending') || normalized.contains('not active');

    return (mentionsEmail && asksForConfirmation) || isPendingAccount;
  }

  Future<String> _requestConfirmationCode(String email) async {
    try {
      return await _resendConfirmationUseCase(email: email);
    } catch (_) {
      return 'Account created. Use resend code if the verification email does not arrive.';
    }
  }
}
