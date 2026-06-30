part of '../profile_header.dart';

class ProfileHeader extends StatelessWidget {
  final VoidCallback? onMenuPressed;
  final VoidCallback? onEditProfilePressed;
  final UserEntity? user;
  final bool isLoading;

  const ProfileHeader({
    super.key,
    this.onMenuPressed,
    this.onEditProfilePressed,
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
          ProfileHeaderBackground(
            topPadding: topPadding,
            onMenuPressed: onMenuPressed,
          ),
          Positioned(
            top: topPadding + 112,
            left: 24,
            right: 24,
            child: Column(
              children: [
                ProfessionalProfileAvatar(
                  name: displayName,
                  user: user,
                  onEditPressed: onEditProfilePressed,
                ),
                const SizedBox(height: 14),
                if (isLoading)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2.4),
                  )
                else if (displayName.isNotEmpty)
                  _ProfileDetails(
                    displayName: displayName,
                    email: email,
                    phone: phone,
                    role: role,
                    textColor: colorScheme.onSurface,
                    mutedTextColor: colorScheme.onSurfaceVariant,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _displayName(AppLocalizations l10n) {
    final name = user?.name.trim();
    if (name != null && name.isNotEmpty) return name;

    final email = user?.email.trim();
    if (email != null && email.isNotEmpty) return email.split('@').first;

    return l10n.myAccount;
  }
}
