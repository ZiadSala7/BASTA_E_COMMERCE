// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../auth/domain/entities/user_entity.dart';

class ProfessionalProfileAvatar extends StatelessWidget {
  final String name;
  final UserEntity? user;

  const ProfessionalProfileAvatar({
    super.key,
    required this.name,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final initials = _initials(name);
    final isVerified = (user?.status ?? '').toUpperCase() == 'ACTIVE';

    return Stack(
      clipBehavior: Clip.none,
      children: [
        _AvatarCircle(initials: initials),
        if (isVerified) const _VerifiedBadge(),
        const _EditBadge(),
      ],
    );
  }

  String _initials(String value) {
    final parts = value
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'U';

    final first = parts.first.characters.first;
    final second = parts.length > 1 ? parts[1].characters.first : '';
    return (first + second).toUpperCase();
  }
}

class _AvatarCircle extends StatelessWidget {
  final String initials;

  const _AvatarCircle({required this.initials});

  @override
  Widget build(BuildContext context) {
    return Container(
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
            colors: [Color(0xFF4747C2), Color(0xFF5B5BD6), Color(0xFF20B7A8)],
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
    );
  }
}

class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge();

  @override
  Widget build(BuildContext context) {
    return PositionedDirectional(
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
    );
  }
}

class _EditBadge extends StatelessWidget {
  const _EditBadge();

  @override
  Widget build(BuildContext context) {
    return PositionedDirectional(
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
    );
  }
}
