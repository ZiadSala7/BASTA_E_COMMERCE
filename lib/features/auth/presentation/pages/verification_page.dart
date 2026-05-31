import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/app_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubits/auth_cubit.dart';
import '../models/auth_verification_args.dart';
import '../utils/auth_validators.dart';
import '../widgets/auth_otp_input_row.dart';
import '../widgets/auth_page_heading.dart';
import '../widgets/auth_page_scaffold.dart';
import '../widgets/auth_primary_button.dart';

class VerificationPage extends StatefulWidget {
  final AuthVerificationArgs arguments;

  const VerificationPage({super.key, required this.arguments});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  static const int _resendCooldownSeconds = 20;

  String _code = '';
  String? _errorText;
  Timer? _resendTimer;
  int _remainingSeconds = _resendCooldownSeconds;

  bool get _canResendCode {
    return widget.arguments.flow != AuthVerificationFlow.passwordReset &&
        (widget.arguments.email?.isNotEmpty ?? false);
  }

  @override
  void initState() {
    super.initState();
    if (_canResendCode) {
      _startResendTimer();
    } else {
      _remainingSeconds = 0;
    }
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    super.dispose();
  }

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

  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() {
      _remainingSeconds = _resendCooldownSeconds;
    });

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_remainingSeconds <= 1) {
        timer.cancel();
        setState(() {
          _remainingSeconds = 0;
        });
        return;
      }

      setState(() {
        _remainingSeconds--;
      });
    });
  }

  String _formatRemainingTime() {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String _resendButtonLabel(AppLocalizations localizations) {
    if (_remainingSeconds > 0) {
      return localizations.resendCodeIn(_formatRemainingTime());
    }

    return localizations.resendCodeAction;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthEmailConfirmed) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));

          // After email confirmation, handle different flows
          if (widget.arguments.flow == AuthVerificationFlow.emailConfirmation) {
            // For registration flow, use cached credentials to login
            if (widget.arguments.email != null && widget.arguments.password != null) {
              context.read<AuthCubit>().login(
                widget.arguments.email!,
                widget.arguments.password!,
                rememberSession: true,
              );
            } else {
              // If no cached credentials, go to login page
              context.go(AppRoutes.login);
            }
          } else {
            // For password reset or other flows, go to appropriate page
            context.go(AppRoutes.login);
          }
        }

        if (state is AuthAuthenticated) {
          context.go(AppRoutes.mainNavigation);
        }

        if (state is AuthConfirmationCodeSent) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
          _startResendTimer();
        }

        if (state is AuthError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        return AuthPageScaffold(
          showBackButton: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              AuthPageHeading(
                title: localizations.verificationTitle,
                subtitle: localizations.verificationSubtitle(
                  widget.arguments.destination,
                ),
              ),
              const SizedBox(height: 28),
              AuthOtpInputRow(
                onChanged: (value) {
                  setState(() {
                    _code = value;
                    _errorText = null;
                  });
                },
              ),
              if (_errorText != null) ...[
                const SizedBox(height: 8),
                Text(
                  _errorText!,
                  style: const TextStyle(
                    color: Color(0xFFE25B5B),
                    fontSize: 12,
                  ),
                ),
              ],
              const SizedBox(height: 28),
              AuthPrimaryButton(
                label: localizations.continueAction,
                isLoading: state is AuthLoading,
                onPressed: _submit,
              ),
              const SizedBox(height: 22),
              Center(
                child: TextButton(
                  onPressed:
                      state is AuthLoading ||
                          !_canResendCode ||
                          _remainingSeconds > 0
                      ? null
                      : _resendCode,
                  child: Text(
                    _resendButtonLabel(localizations),
                    style: const TextStyle(
                      color: Color(0xFF8E90A6),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
