part of '../profile_header_background.dart';

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
