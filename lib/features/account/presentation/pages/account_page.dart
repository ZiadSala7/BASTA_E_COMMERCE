// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/extensions/app_localizations_x.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_router.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../../l10n/app_localizations.dart';

class AccountPage extends StatelessWidget {
  final VoidCallback? onMenuPressed;

  const AccountPage({super.key, this.onMenuPressed});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthCubit>()..getCurrentUser(),
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
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.go(AppRoutes.login);
        }

        if (state is AuthError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        final user = _userFromState(state);
        final isLoading = state is AuthLoading && user == null;

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: RefreshIndicator(
            onRefresh: () => context.read<AuthCubit>().getCurrentUser(),
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _ProfileHeader(
                  onMenuPressed: onMenuPressed,
                  user: user,
                  isLoading: isLoading,
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: _AccountStatsPanel(),
                ),
                const _MenuSection(),
                const SizedBox(height: 16),
                const _SupportSection(),
                const SizedBox(height: 16),
                const _SettingsSection(),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _LogoutButton(isLoading: state is AuthLoading),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  UserEntity? _userFromState(AuthState state) {
    if (state is AuthAuthenticated) {
      return state.user;
    }

    if (state is AuthProfileUpdated) {
      return state.user;
    }

    return null;
  }
}

class _ProfileHeader extends StatelessWidget {
  final VoidCallback? onMenuPressed;
  final UserEntity? user;
  final bool isLoading;

  const _ProfileHeader({
    this.onMenuPressed,
    required this.user,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final topPadding = MediaQuery.paddingOf(context).top;
    final colorScheme = Theme.of(context).colorScheme;
    final displayName = _displayName(l10n);
    final email = user?.email.trim() ?? '';
    final phone = user?.phone?.trim() ?? '';
    final role = user?.role?.trim() ?? '';

    return SizedBox(
      height: topPadding + 342,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(34),
            ),
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF4747C2),
                    Color(0xFF5B5BD6),
                    Color(0xFF20B7A8),
                  ],
                ),
              ),
              child: SizedBox(
                height: topPadding + 176,
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, topPadding + 14, 20, 0),
                  child: Column(
                    children: [
                      Row(
                        textDirection: l10n.inverseAppBarDirection,
                        children: [
                          _HeaderIconButton(
                            icon: Icons.menu_rounded,
                            onTap: onMenuPressed,
                          ),
                          const SizedBox(width: 10),
                          _HeaderIconButton(
                            icon: Icons.notifications_none_rounded,
                            onTap: () => context.push(AppRoutes.notifications),
                            showDot: true,
                          ),
                          const Spacer(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                l10n.myAccount,
                                style: GoogleFonts.cairo(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  height: 1.05,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                l10n.editAccount,
                                style: GoogleFonts.cairo(
                                  color: Colors.white.withOpacity(0.78),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  height: 1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.16),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.22),
                              ),
                            ),
                            child: const Icon(
                              Icons.person_outline_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: topPadding + 112,
            left: 24,
            right: 24,
            child: Column(
              children: [
                _ProfessionalProfileAvatar(name: displayName, user: user),
                const SizedBox(height: 14),
                if (isLoading)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2.4),
                  )
                else ...[
                  Text(
                    displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      color: colorScheme.onSurface,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                    ),
                  ),
                  if (email.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (phone.isNotEmpty)
                        _ProfileInfoChip(
                          icon: Icons.phone_outlined,
                          label: phone,
                        ),
                      if (role.isNotEmpty)
                        _ProfileInfoChip(
                          icon: Icons.badge_outlined,
                          label: role,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _displayName(AppLocalizations l10n) {
    final name = user?.name.trim();
    if (name != null && name.isNotEmpty) {
      return name;
    }

    return l10n.profileDisplayName;
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool showDot;

  const _HeaderIconButton({
    required this.icon,
    this.onTap,
    this.showDot = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.14),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 42,
          height: 42,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 22),
              if (showDot)
                PositionedDirectional(
                  top: 9,
                  end: 9,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.badgeRed,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.2),
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

class _ProfessionalProfileAvatar extends StatelessWidget {
  final String name;
  final UserEntity? user;

  const _ProfessionalProfileAvatar({required this.name, required this.user});

  @override
  Widget build(BuildContext context) {
    final initials = _initials(name);
    final isVerified = (user?.status ?? '').toUpperCase() == 'ACTIVE';

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 122,
          height: 122,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Color(0xFFEAF8F5)],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.18),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF4747C2),
                  Color(0xFF5B5BD6),
                  Color(0xFF20B7A8),
                ],
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                PositionedDirectional(
                  top: 18,
                  end: 18,
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white.withOpacity(0.22),
                    size: 20,
                  ),
                ),
                Text(
                  initials,
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isVerified)
          PositionedDirectional(
            start: 4,
            bottom: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.accentGreen,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentGreen.withOpacity(0.28),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.verified_rounded,
                color: Colors.white,
                size: 17,
              ),
            ),
          ),
        PositionedDirectional(
          end: 0,
          bottom: 8,
          child: Material(
            color: AppColors.accent,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: () {},
              customBorder: const CircleBorder(),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.edit_outlined,
                  color: Colors.white,
                  size: 21,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _initials(String value) {
    final parts = value
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return 'U';
    }

    final first = parts.first.characters.first;
    final second = parts.length > 1 ? parts[1].characters.first : '';
    return (first + second).toUpperCase();
  }
}

class _ProfileInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ProfileInfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      constraints: const BoxConstraints(maxWidth: 190),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.primary.withOpacity(0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.primary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.cairo(
                color: colorScheme.onSurface,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountStatsPanel extends StatelessWidget {
  const _AccountStatsPanel();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _AccountStat(
              icon: Icons.inventory_2_outlined,
              label: l10n.myOrders,
              value: '12',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _AccountStat(
              icon: Icons.local_offer_outlined,
              label: l10n.coupons,
              value: '4',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _AccountStat(
              icon: Icons.favorite_border_rounded,
              label: l10n.favorites,
              value: '8',
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountStat extends StatelessWidget {
  const _AccountStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 86,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 21),
          const SizedBox(height: 7),
          Text(
            value,
            style: GoogleFonts.cairo(
              color: colorScheme.onSurface,
              fontSize: 17,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.cairo(
              color: colorScheme.onSurfaceVariant,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  const _MenuSection();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return _Section(
      children: [
        _MenuItem(
          icon: Icons.shopping_bag_outlined,
          title: l10n.myOrders,
          onTap: () {},
          showBadge: true,
          badgeCount: 3,
        ),
        const _Divider(),
        _MenuItem(icon: Icons.location_on_outlined, title: l10n.myAddresses),
        const _Divider(),
        _MenuItem(icon: Icons.credit_card_outlined, title: l10n.paymentMethods),
        const _Divider(),
        _MenuItem(icon: Icons.favorite_border_outlined, title: l10n.favorites),
        const _Divider(),
        _MenuItem(icon: Icons.card_giftcard_outlined, title: l10n.coupons),
      ],
    );
  }
}

class _SupportSection extends StatelessWidget {
  const _SupportSection();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return _Section(
      title: l10n.supportAndHelp,
      children: [
        _MenuItem(icon: Icons.help_outline, title: l10n.faq),
        const _Divider(),
        _MenuItem(icon: Icons.contact_support_outlined, title: l10n.contactUs),
        const _Divider(),
        _MenuItem(icon: Icons.policy_outlined, title: l10n.privacyPolicy),
      ],
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return _Section(
      title: l10n.settings,
      children: [
        _MenuItem(
          icon: Icons.language_outlined,
          title: l10n.language,
          subtitle: l10n.isArabic ? l10n.arabic : l10n.english,
        ),
        const _Divider(),
        _MenuItem(
          icon: Icons.notifications_none,
          title: l10n.notificationSettings,
          showSwitch: true,
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  final String? title;
  final List<Widget> children;

  const _Section({this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                title!,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ...children,
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool showBadge;
  final int? badgeCount;
  final bool showSwitch;

  const _MenuItem({
    required this.icon,
    required this.title,
    this.onTap,
    this.subtitle,
    this.showBadge = false,
    this.badgeCount,
    this.showSwitch = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(
                    theme.brightness == Brightness.dark ? 0.18 : 0.10,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.cairo(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (showBadge && badgeCount != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$badgeCount',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              if (showSwitch)
                Switch(
                  value: true,
                  onChanged: (value) {},
                  activeColor: AppColors.primary,
                ),
              if (!showBadge && !showSwitch)
                Icon(
                  Icons.arrow_back_ios_new,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 1,
      color: colorScheme.outlineVariant,
      margin: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final bool isLoading;

  const _LogoutButton({required this.isLoading});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return OutlinedButton.icon(
      onPressed: isLoading ? null : () => context.read<AuthCubit>().logout(),
      icon: isLoading
          ? SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.red.shade600,
              ),
            )
          : Icon(Icons.logout, color: Colors.red.shade600),
      label: Text(
        l10n.logout,
        style: GoogleFonts.cairo(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.red.shade600,
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: Colors.red.shade600),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
