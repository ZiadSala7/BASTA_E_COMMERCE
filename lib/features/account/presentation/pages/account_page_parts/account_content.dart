part of '../account_page.dart';

class _AccountContent extends StatelessWidget {
  final VoidCallback? onMenuPressed;

  const _AccountContent({this.onMenuPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<AuthCubit, AuthState>(
      listener: _listenToAuthState,
      builder: (context, authState) {
        return BlocConsumer<AccountCubit, AccountState>(
          listener: _listenToAccountState,
          builder: (context, accountState) {
            final user = _userFromState(authState);
            final stats = _statsFromState(accountState);
            final isLoading = authState is AuthLoading && user == null;

            return Scaffold(
              backgroundColor: theme.scaffoldBackgroundColor,
              body: RefreshIndicator(
                onRefresh: () => _refreshAccount(context),
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    ProfileHeader(
                      onMenuPressed: onMenuPressed,
                      onEditProfilePressed: () =>
                          _openEditProfileSheet(context, user),
                      user: user,
                      isLoading: isLoading,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: AccountStatsPanel(stats: stats),
                    ),
                    AccountMenuSection(
                      onEditProfile: () => _openEditProfileSheet(context, user),
                    ),
                    const SizedBox(height: 16),
                    const AccountSupportSection(),
                    const SizedBox(height: 16),
                    const AccountSettingsSection(),
                    const SizedBox(height: 32),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: LogoutButton(isLoading: authState is AuthLoading),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _listenToAuthState(BuildContext context, AuthState state) {
    if (state is AuthUnauthenticated) {
      context.go(AppRoutes.login);
    }

    if (state is AuthProfileUpdated) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.pick(
                ar: 'Profile updated successfully',
                en: 'Profile updated successfully',
              ),
            ),
          ),
        );
    }

    if (state is AuthProfileEmailVerificationRequired) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(state.message)));
      context.go(
        AppRoutes.verification,
        extra: AuthVerificationArgs.emailConfirmation(email: state.email),
      );
    }

    if (state is AuthError) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(state.message)));
    }
  }

  void _listenToAccountState(BuildContext context, AccountState state) {
    if (state is AccountError) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(state.message)));
    }
  }

  Future<void> _refreshAccount(BuildContext context) async {
    await Future.wait([
      context.read<AuthCubit>().getCurrentUser(),
      context.read<AccountCubit>().getAccountStats(),
    ]);
  }

  void _openEditProfileSheet(BuildContext context, UserEntity? user) {
    final authCubit = context.read<AuthCubit>();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => BlocProvider.value(
        value: authCubit,
        child: EditProfileSheet(user: user),
      ),
    );
  }

  AccountStatsEntity? _statsFromState(AccountState state) {
    if (state is AccountStatsLoaded) {
      return state.stats;
    }

    return null;
  }

  UserEntity? _userFromState(AuthState state) {
    if (state is AuthAuthenticated) {
      log('AuthAuthenticated user: ${state.user.name} (${state.user.email})');
      return state.user;
    }

    if (state is AuthProfileUpdated) {
      log('AuthProfileUpdated user: ${state.user.name} (${state.user.email})');
      return state.user;
    }

    log('No user found in state: $state');
    return null;
  }
}
