import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/extensions/app_localizations_x.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/domain/entities/user_entity.dart';
import 'profile_header_background.dart';
import 'profile_info_chip.dart';
import 'professional_profile_avatar.dart';

class ProfileHeader extends StatelessWidget {
  final VoidCallback? onMenuPressed;
  final UserEntity? user;
  final bool isLoading;

  const ProfileHeader({
    super.key,
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
                ProfessionalProfileAvatar(name: displayName, user: user),
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

class _ProfileDetails extends StatelessWidget {
  final String displayName;
  final String email;
  final String phone;
  final String role;
  final Color textColor;
  final Color mutedTextColor;

  const _ProfileDetails({
    required this.displayName,
    required this.email,
    required this.phone,
    required this.role,
    required this.textColor,
    required this.mutedTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          displayName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(
            color: textColor,
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
              color: mutedTextColor,
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
              ProfileInfoChip(icon: Icons.phone_outlined, label: phone),
            if (role.isNotEmpty)
              ProfileInfoChip(icon: Icons.badge_outlined, label: role),
          ],
        ),
      ],
    );
  }
}
