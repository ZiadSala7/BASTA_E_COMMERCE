import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

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

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go(AppRoutes.home);
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AuthBrandHeader(),
                const SizedBox(height: 36),
                AuthPageHeading(
                  title: localizations.registerTitle,
                  subtitle: localizations.registerSubtitle,
                ),
                const SizedBox(height: 22),
                AuthTextField(
                  controller: _nameController,
                  hintText: localizations.fullNameHint,
                  validator: (value) =>
                      AuthValidators.name(value, localizations),
                  prefixIcon: const Icon(
                    Icons.person_outline_rounded,
                    color: Color(0xFF9CA0B6),
                  ),
                ),
                const SizedBox(height: 14),
                AuthTextField(
                  controller: _phoneController,
                  hintText: localizations.phoneHint,
                  keyboardType: TextInputType.phone,
                  validator: (value) =>
                      AuthValidators.phone(value, localizations),
                  prefixIcon: const Icon(
                    Icons.phone_outlined,
                    color: Color(0xFF9CA0B6),
                  ),
                ),
                const SizedBox(height: 14),
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
                  validator: (value) =>
                      AuthValidators.password(value, localizations),
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: Color(0xFF9CA0B6),
                  ),
                ),
                const SizedBox(height: 14),
                AuthTextField(
                  controller: _confirmPasswordController,
                  hintText: localizations.confirmPasswordHint,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  validator: (value) => AuthValidators.confirmPassword(
                    value,
                    _passwordController.text,
                    localizations,
                  ),
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: Color(0xFF9CA0B6),
                  ),
                ),
                const SizedBox(height: 18),
                AuthPrimaryButton(
                  label: localizations.createAccountButton,
                  isLoading: state is AuthLoading,
                  onPressed: _submit,
                ),
                const SizedBox(height: 26),
                const AuthSocialActions(),
                const SizedBox(height: 22),
                AuthFooterLink(
                  prompt: localizations.alreadyHaveAccountPrompt,
                  action: localizations.loginAction,
                  onTap: () => context.go(AppRoutes.login),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
