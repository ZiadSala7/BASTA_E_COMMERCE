part of '../edit_profile_sheet.dart';

class _EditProfileSheetState extends State<EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;

  String get _initialName => widget.user?.name.trim() ?? '';
  String get _initialPhone => widget.user?.phone?.trim() ?? '';
  String get _initialEmail => widget.user?.email.trim() ?? '';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _initialName);
    _phoneController = TextEditingController(text: _initialPhone);
    _emailController = TextEditingController(text: _initialEmail);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final name = _changedValue(_nameController.text, _initialName);
    final phone = _changedValue(_phoneController.text, _initialPhone);
    final email = _changedValue(_emailController.text, _initialEmail);
    final l10n = AppLocalizations.of(context)!;

    if (name == null && phone == null && email == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              l10n.pick(
                ar: 'No profile changes to save',
                en: 'No profile changes to save',
              ),
            ),
          ),
        );
      return;
    }

    context.read<AuthCubit>().updateProfile(
      name: name,
      phone: phone,
      email: email,
    );
  }

  String? _changedValue(String value, String original) {
    final normalized = value.trim();
    if (normalized == original.trim()) return null;
    if (normalized.isEmpty) return null;
    return normalized;
  }

  String? _validateName(String? value, AppLocalizations l10n) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return l10n.nameRequired;
    if (name.length < 2) {
      return l10n.pick(
        ar: 'Name must be at least 2 characters',
        en: 'Name must be at least 2 characters',
      );
    }
    return null;
  }

  String? _validateEmail(String? value, AppLocalizations l10n) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return l10n.emailRequired;

    const pattern = r'^[^@\s]+@[^@\s]+\.[^@\s]+$';
    if (!RegExp(pattern).hasMatch(email)) return l10n.invalidEmail;

    return null;
  }

  String? _validatePhone(String? value, AppLocalizations l10n) {
    final phone = value?.trim() ?? '';
    if (phone.isEmpty) return null;

    const pattern = r'^\+?[0-9]{8,15}$';
    if (!RegExp(pattern).hasMatch(phone)) return l10n.invalidPhone;

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthProfileUpdated ||
            state is AuthProfileEmailVerificationRequired) {
          Navigator.of(context).maybePop();
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return AnimatedPadding(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(bottom: bottomInset),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: colorScheme.outlineVariant,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      l10n.editAccount,
                      style: GoogleFonts.cairo(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.pick(
                        ar: 'Update your name, phone number, or email address',
                        en: 'Update your name, phone number, or email address',
                      ),
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _ProfileField(
                      controller: _nameController,
                      label: l10n.fullNameHint,
                      icon: Icons.person_outline,
                      textInputAction: TextInputAction.next,
                      validator: (value) => _validateName(value, l10n),
                    ),
                    const SizedBox(height: 12),
                    _ProfileField(
                      controller: _phoneController,
                      label: l10n.phoneHint,
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      validator: (value) => _validatePhone(value, l10n),
                    ),
                    const SizedBox(height: 12),
                    _ProfileField(
                      controller: _emailController,
                      label: l10n.emailHint,
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      validator: (value) => _validateEmail(value, l10n),
                      onFieldSubmitted: (_) {
                        if (!isLoading) _submit();
                      },
                    ),
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      onPressed: isLoading ? null : _submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save_outlined),
                      label: Text(
                        l10n.pick(ar: 'Save changes', en: 'Save changes'),
                        style: GoogleFonts.cairo(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
