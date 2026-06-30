part of '../reset_password_page.dart';

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _tokenController;
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tokenController = TextEditingController(
      text: widget.arguments?.token ?? '',
    );
  }

  @override
  void dispose() {
    _tokenController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    context.read<AuthCubit>().resetPassword(
      _tokenController.text.trim(),
      _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthPasswordReset) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
          context.go(AppRoutes.login);
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                AuthPageHeading(
                  title: localizations.resetPasswordTitle,
                  subtitle: localizations.resetPasswordSubtitle,
                ),
                const SizedBox(height: 26),
                AuthTextField(
                  controller: _tokenController,
                  hintText: localizations.resetTokenHint,
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) {
                      return localizations.resetTokenRequired;
                    }
                    return null;
                  },
                  prefixIcon: const Icon(
                    Icons.key_outlined,
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
                const SizedBox(height: 30),
                AuthPrimaryButton(
                  label: localizations.resetPasswordButton,
                  isLoading: state is AuthLoading,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
