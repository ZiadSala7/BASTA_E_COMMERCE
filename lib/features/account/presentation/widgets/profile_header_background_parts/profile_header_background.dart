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
    final l10n = AppLocalizations.of(context)!;

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
