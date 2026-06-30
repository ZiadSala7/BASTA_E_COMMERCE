part of '../professional_profile_avatar.dart';

class ProfessionalProfileAvatar extends StatelessWidget {
  final String name;
  final UserEntity? user;
  final VoidCallback? onEditPressed;

  const ProfessionalProfileAvatar({
    super.key,
    required this.name,
    required this.user,
    this.onEditPressed,
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
        _EditBadge(onPressed: onEditPressed),
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
