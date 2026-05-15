import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubits/auth_cubit.dart';
import '../utils/auth_validators.dart';
import '../widgets/auth_brand_header.dart';
import '../widgets/auth_footer_link.dart';
import '../widgets/auth_page_heading.dart';
import '../widgets/auth_page_scaffold.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_social_actions.dart';
import '../widgets/auth_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _rememberMe = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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

  void _toggleRememberMe() {
    setState(() {
      _rememberMe = !_rememberMe;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go(AppRoutes.mainNavigation);
        }

        if (state is AuthError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        return AuthPageScaffold(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const AuthBrandHeader(),
                const SizedBox(height: 36),
                AuthPageHeading(
                  title: localizations.loginTitle,
                  subtitle: localizations.loginSubtitle,
                ),
                const SizedBox(height: 22),
                AuthTextField(
                  controller: _emailController,
                  hintText: localizations.emailHint,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) =>
                      AuthValidators.email(value, localizations),
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: Color(0xFF9CA0B6),
                  ),
                ),
                const SizedBox(height: 14),
                AuthTextField(
                  controller: _passwordController,
                  hintText: localizations.passwordHint,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  validator: (value) =>
                      AuthValidators.password(value, localizations),
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: Color(0xFF9CA0B6),
                  ),
                ),
                const SizedBox(height: 10),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxWidth < 360;

                    if (compact) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              _RememberMeIconButton(
                                value: _rememberMe,
                                onPressed: _toggleRememberMe,
                              ),
                              Text(
                                localizations.rememberMe,
                                style: AppTextStyles.authSecondaryText(context),
                              ),
                              const Spacer(),
                              TextButton(
                                onPressed: () =>
                                    context.push(AppRoutes.forgotPassword),
                                child: Text(
                                  localizations.forgotPasswordQuestion,
                                  style: AppTextStyles.authLinkText(
                                    context,
                                  ).copyWith(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    }

                    return Row(
                      children: [
                        _RememberMeIconButton(
                          value: _rememberMe,
                          onPressed: _toggleRememberMe,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            localizations.rememberMe,
                            style: AppTextStyles.authSecondaryText(context),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        TextButton(
                          onPressed: () =>
                              context.push(AppRoutes.forgotPassword),
                          child: Text(localizations.forgotPasswordQuestion),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 10),
                AuthPrimaryButton(
                  label: localizations.loginButton,
                  isLoading: state is AuthLoading,
                  onPressed: _submit,
                ),
                const SizedBox(height: 12),
                // Direct navigation button to main navigation
                OutlinedButton(
                  onPressed: () {
                    context.go(AppRoutes.mainNavigation);
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF5468F6)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    minimumSize: const Size(double.infinity, 56),
                  ),
                  child: Text(
                    localizations.enterAppButton,
                    style: AppTextStyles.authPrimaryButton(context).copyWith(
                      color: const Color(0xFF5468F6),
                    ),
                  ),
                ),
                const SizedBox(height: 26),
                const AuthSocialActions(),
                const SizedBox(height: 22),
                AuthFooterLink(
                  prompt: localizations.dontHaveAccountPrompt,
                  action: localizations.createAccountAction,
                  onTap: () => context.push(AppRoutes.register),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RememberMeIconButton extends StatelessWidget {
  final bool value;
  final VoidCallback onPressed;

  const _RememberMeIconButton({required this.value, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 34, minHeight: 28),
      icon: Icon(
        value ? Icons.toggle_on_rounded : Icons.toggle_off_rounded,
        color: value ? const Color(0xFF5B6BFF) : const Color(0xFFB1B4C8),
        size: 34,
      ),
    );
  }
}
