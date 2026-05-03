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

  const VerificationPage({
    super.key,
    required this.arguments,
  });

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  String _code = '';
  String? _errorText;

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
      context.go(AppRoutes.login);
      return;
    }

    context.read<AuthCubit>().register(
      widget.arguments.email!,
      widget.arguments.password!,
      widget.arguments.name!,
      widget.arguments.phone ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go(AppRoutes.home);
        }

        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
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
                child: Text(
                  localizations.resendCodeIn('0:20'),
                  style: const TextStyle(
                    color: Color(0xFF8E90A6),
                    fontSize: 14,
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
