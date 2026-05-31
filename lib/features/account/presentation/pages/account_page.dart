import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/app_router.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../domain/entities/account_stats_entity.dart';
import '../cubits/account_cubit.dart';
import '../widgets/account_menu_sections.dart';
import '../widgets/account_stats_panel.dart';
import '../widgets/logout_button.dart';
import '../widgets/profile_header.dart';

class AccountPage extends StatelessWidget {
  final VoidCallback? onMenuPressed;

  const AccountPage({super.key, this.onMenuPressed});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<AuthCubit>()..getCurrentUser()),
        BlocProvider(create: (_) => sl<AccountCubit>()..getAccountStats()),
      ],
      child: _AccountContent(onMenuPressed: onMenuPressed),
    );
  }
}

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
                      user: user,
                      isLoading: isLoading,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: AccountStatsPanel(stats: stats),
                    ),
                    const AccountMenuSection(),
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
