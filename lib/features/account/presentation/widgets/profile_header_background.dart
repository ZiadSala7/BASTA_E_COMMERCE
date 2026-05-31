// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/extensions/app_localizations_x.dart';
import '../../../../core/utils/app_router.dart';
import '../../../../l10n/app_localizations.dart';
import 'header_icon_button.dart';

class ProfileHeaderBackground extends StatelessWidget {
  final double topPadding;
  final VoidCallback? onMenuPressed;

  const ProfileHeaderBackground({
    super.key,
    required this.topPadding,
    this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(34)),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF4747C2), Color(0xFF5B5BD6), Color(0xFF20B7A8)],
          ),
        ),
        child: SizedBox(
          height: topPadding + 176,
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, topPadding + 14, 20, 0),
            child: Row(
              textDirection: l10n.inverseAppBarDirection,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HeaderIconButton(
                  icon: Icons.menu_rounded,
                  onTap: onMenuPressed,
                ),
                const SizedBox(width: 10),
                HeaderIconButton(
                  icon: Icons.notifications_none_rounded,
                  onTap: () => context.push(AppRoutes.notifications),
                  showDot: true,
                ),
                const Spacer(),
                const _AccountTitleBlock(),
                const SizedBox(width: 12),
                const _AccountIcon(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountTitleBlock extends StatelessWidget {
  const _AccountTitleBlock();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
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
    );
  }
}

class _AccountIcon extends StatelessWidget {
  const _AccountIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.22)),
      ),
      child: const Icon(
        Icons.person_outline_rounded,
        color: Colors.white,
        size: 24,
      ),
    );
  }
}
