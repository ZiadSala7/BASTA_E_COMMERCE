part of '../login_page.dart';

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

        if (state is AuthEmailConfirmationRequired) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
          context.push(
            AppRoutes.verification,
            extra: AuthVerificationArgs.emailConfirmation(email: state.email),
          );
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
                const SizedBox(height: 26),
                AuthSocialActions(
                  onGoogleTap: state is AuthLoading
                      ? null
                      : () => context.read<AuthCubit>().loginWithGoogle(
                          rememberSession: _rememberMe,
                        ),
                ),
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
