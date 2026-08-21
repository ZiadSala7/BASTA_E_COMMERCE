// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../features/account/domain/entities/account_stats_entity.dart';
import '../../features/account/domain/usecases/get_account_stats_usecase.dart';
import '../../features/auth/domain/entities/user_entity.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../l10n/app_localizations.dart';
import '../di/service_locator.dart';
import '../extensions/app_localizations_x.dart';
import '../managers/language_cubit.dart';
import '../managers/language_state.dart';
import '../managers/theme_cubit.dart';
import '../managers/theme_state.dart';
import '../utils/app_colors.dart';
import '../utils/app_router.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    void openRoute(String route) {
      Navigator.of(context).maybePop();
      context.push(route);
    }

    return Drawer(
      width: 318,
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsetsDirectional.only(start: 12, bottom: 12),
          child: ClipRRect(
            borderRadius: const BorderRadiusDirectional.horizontal(
              end: Radius.circular(28),
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(
                      theme.brightness == Brightness.dark ? 0.34 : 0.14,
                    ),
                    blurRadius: 32,
                    offset: const Offset(8, 0),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const _DrawerProfileHeader(),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                      children: [
                        _DrawerSection(
                          title: l10n.information,
                          children: [
                            _DrawerItem(
                              label: l10n.favorites,
                              icon: Icons.favorite_border_rounded,
                              onTap: () => openRoute(AppRoutes.favorites),
                            ),
                            _DrawerItem(
                              label: l10n.myOrders,
                              icon: Icons.inventory_2_outlined,
                              onTap: () => openRoute(AppRoutes.orders),
                            ),
                            _DrawerItem(
                              label: l10n.addresses,
                              icon: Icons.location_on_outlined,
                              onTap: () => openRoute(AppRoutes.addresses),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _DrawerSection(
                          title: l10n.supportAndHelp,
                          children: [
                            _DrawerItem(
                              label: l10n.faq,
                              icon: Icons.help_outline_rounded,
                              onTap: () => openRoute(AppRoutes.faq),
                            ),
                            _DrawerItem(
                              label: l10n.contactUs,
                              icon: Icons.contact_support_outlined,
                              onTap: () => openRoute(AppRoutes.contactUs),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _DrawerSection(
                          title: l10n.accountSettings,
                          children: [
                            const _LanguageItem(),
                            const _ThemeModeItem(),
                            _DrawerItem(
                              label: l10n.inviteFriends,
                              icon: Icons.group_add_outlined,
                              onTap: () => openRoute(AppRoutes.inviteFriends),
                            ),
                            _DrawerItem(
                              label: l10n.privacyPolicy,
                              icon: Icons.shield_outlined,
                              onTap: () => openRoute(AppRoutes.privacyPolicy),
                            ),
                            _DrawerItem(
                              label: l10n.aboutUs,
                              icon: Icons.info_outline_rounded,
                              onTap: () => openRoute(AppRoutes.aboutUs),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                    child: _LogoutTile(label: l10n.logout),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DrawerProfileHeader extends StatefulWidget {
  const _DrawerProfileHeader();

  @override
  State<_DrawerProfileHeader> createState() => _DrawerProfileHeaderState();
}

class _DrawerProfileHeaderState extends State<_DrawerProfileHeader> {
  late final Future<_DrawerProfileData> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfileData();
  }

  Future<_DrawerProfileData> _loadProfileData() async {
    final results = await Future.wait<Object?>([_loadUser(), _loadStats()]);

    return _DrawerProfileData(
      user: results[0] as UserEntity?,
      stats: results[1] as AccountStatsEntity?,
    );
  }

  Future<UserEntity?> _loadUser() async {
    try {
      return await sl<GetCurrentUserUseCase>()();
    } catch (_) {
      return null;
    }
  }

  Future<AccountStatsEntity?> _loadStats() async {
    try {
      return await sl<GetAccountStatsUseCase>()();
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return FutureBuilder<_DrawerProfileData>(
      future: _profileFuture,
      builder: (context, snapshot) {
        final user = snapshot.data?.user;
        final stats = snapshot.data?.stats;
        final displayName = _displayName(l10n, user);
        final email = user?.email.trim() ?? '';

        return _DrawerProfileHeaderView(
          displayName: displayName,
          email: email,
          stats: stats,
        );
      },
    );
  }

  String _displayName(AppLocalizations l10n, UserEntity? user) {
    final name = user?.name.trim();
    if (name != null && name.isNotEmpty) return name;

    final email = user?.email.trim();
    if (email != null && email.isNotEmpty) return email.split('@').first;

    return l10n.profileDisplayName;
  }
}

class _DrawerProfileData {
  final UserEntity? user;
  final AccountStatsEntity? stats;

  const _DrawerProfileData({required this.user, required this.stats});
}

class _DrawerProfileHeaderView extends StatelessWidget {
  final String displayName;
  final String email;
  final AccountStatsEntity? stats;

  const _DrawerProfileHeaderView({
    required this.displayName,
    required this.email,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primary],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            textDirection: l10n.inverseAppBarDirection,
            children: [
              _DrawerHeaderAction(
                icon: Icons.close_rounded,
                onTap: () => Navigator.of(context).maybePop(),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    l10n.myAccount,
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      height: 1.05,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    l10n.currentLanguageLabel,
                    style: GoogleFonts.cairo(
                      color: Colors.white.withOpacity(0.76),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            textDirection: l10n.inverseAppBarDirection,
            children: [
              const _ProfilePhoto(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
                    if (email.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cairo(
                          color: Colors.white.withOpacity(0.78),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _DrawerMetric(
                  label: l10n.myOrders,
                  value: '${stats?.ordersCount ?? 0}',
                  icon: Icons.inventory_2_outlined,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _DrawerMetric(
                  label: l10n.favorites,
                  value: '${stats?.favoritesCount ?? 0}',
                  icon: Icons.favorite_border_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DrawerHeaderAction extends StatelessWidget {
  const _DrawerHeaderAction({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.14),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, color: Colors.white, size: 21),
        ),
      ),
    );
  }
}

class _ProfilePhoto extends StatelessWidget {
  const _ProfilePhoto();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.24),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2.4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.14),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(3),
      child: ClipOval(
        child: Image.asset('assets/images/app_logo.png', fit: BoxFit.cover),
      ),
    );
  }
}

class _DrawerMetric extends StatelessWidget {
  const _DrawerMetric({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.16)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 17),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.cairo(
                  color: Colors.white.withOpacity(0.76),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DrawerSection extends StatelessWidget {
  const _DrawerSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(
            start: 4,
            end: 4,
            bottom: 8,
          ),
          child: Text(
            title,
            textAlign: TextAlign.right,
            style: GoogleFonts.cairo(
              color: colorScheme.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withOpacity(0.36),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: colorScheme.outlineVariant.withOpacity(0.7),
            ),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({required this.label, required this.icon, this.onTap});

  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final rowDirection = l10n.isArabic ? TextDirection.rtl : TextDirection.ltr;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            textDirection: rowDirection,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(
                    theme.brightness == Brightness.dark ? 0.18 : 0.10,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary, size: 19),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: l10n.isArabic ? TextAlign.right : TextAlign.left,
                  style: GoogleFonts.cairo(
                    color: colorScheme.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                l10n.isArabic
                    ? Icons.chevron_left_rounded
                    : Icons.chevron_right_rounded,
                color: colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageItem extends StatelessWidget {
  const _LanguageItem();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageCubit, LanguageState>(
      builder: (context, state) {
        final l10n = AppLocalizations.of(context)!;

        return _DrawerItem(
          label: l10n.currentLanguageLabel,
          icon: Icons.language_rounded,
          onTap: () => context.read<LanguageCubit>().toggleLanguage(),
        );
      },
    );
  }
}

class _ThemeModeItem extends StatelessWidget {
  const _ThemeModeItem();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        final isLight = state.mode == ThemeMode.light;
        final l10n = AppLocalizations.of(context)!;

        return _ToggleDrawerItem(
          label: isLight ? l10n.lightMode : l10n.darkMode,
          icon: isLight ? Icons.wb_sunny_outlined : Icons.dark_mode_outlined,
          value: !isLight,
          onTap: () => context.read<ThemeCubit>().toggleTheme(),
        );
      },
    );
  }
}

class _ToggleDrawerItem extends StatelessWidget {
  const _ToggleDrawerItem({
    required this.label,
    required this.icon,
    required this.value,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final rowDirection = l10n.isArabic ? TextDirection.rtl : TextDirection.ltr;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            textDirection: rowDirection,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(
                    theme.brightness == Brightness.dark ? 0.18 : 0.10,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary, size: 19),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  textAlign: l10n.isArabic ? TextAlign.right : TextAlign.left,
                  style: GoogleFonts.cairo(
                    color: colorScheme.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 44,
                height: 24,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: value ? AppColors.primary : colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 180),
                  alignment: value
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.16),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoutTile extends StatefulWidget {
  const _LogoutTile({required this.label});

  final String label;

  @override
  State<_LogoutTile> createState() => _LogoutTileState();
}

class _LogoutTileState extends State<_LogoutTile> {
  bool _isLoggingOut = false;

  Future<void> _logout() async {
    if (_isLoggingOut) return;

    setState(() => _isLoggingOut = true);
    try {
      await sl<LogoutUseCase>()();
      if (!mounted) return;

      Navigator.of(context).maybePop();
      context.go(AppRoutes.login);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoggingOut = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final rowDirection = l10n.isArabic ? TextDirection.rtl : TextDirection.ltr;

    return Material(
      color: AppColors.badgeRed.withOpacity(0.10),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: _isLoggingOut ? null : _logout,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            textDirection: rowDirection,
            children: [
              _isLoggingOut
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.badgeRed,
                      ),
                    )
                  : const Icon(
                      Icons.logout_rounded,
                      color: AppColors.badgeRed,
                      size: 20,
                    ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.label,
                  textAlign: l10n.isArabic ? TextAlign.right : TextAlign.left,
                  style: GoogleFonts.cairo(
                    color: AppColors.badgeRed,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
