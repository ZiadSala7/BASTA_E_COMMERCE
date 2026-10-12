part of '../profile_header_background.dart';

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
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(34)),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primary],
          ),
        ),
        child: SizedBox(
          height: topPadding + 176,
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, topPadding + 14, 20, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _AccountIcon(),
                const SizedBox(width: 12),
                const _AccountTitleBlock(),
                const Spacer(),
                HeaderIconButton(
                  icon: Icons.notifications_none_rounded,
                  onTap: () => context.push(AppRoutes.notifications),
                  showDot: true,
                ),
                const SizedBox(width: 8),
                HeaderIconButton(
                  icon: Icons.menu_rounded,
                  onTap: onMenuPressed,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
