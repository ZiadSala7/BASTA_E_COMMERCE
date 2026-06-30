part of '../professional_profile_avatar.dart';

class _EditBadge extends StatelessWidget {
  final VoidCallback? onPressed;

  const _EditBadge({this.onPressed});

  @override
  Widget build(BuildContext context) {
    return PositionedDirectional(
      end: 0,
      bottom: 8,
      child: Material(
        color: AppColors.accent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
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
