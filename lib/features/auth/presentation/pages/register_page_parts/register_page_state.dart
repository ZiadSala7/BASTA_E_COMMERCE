part of '../register_page.dart';

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

        if (state is AuthRegistrationPending) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message ?? 'Check your email for the verification code.',
              ),
            ),
          );
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
