part of '../notifications_page.dart';

class _OverviewBadge extends StatelessWidget {
  const _OverviewBadge({required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 42),
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: value > 0
            ? AppColors.badgeRed.withOpacity(0.10)
            : AppColors.primary.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        value > 99 ? '99+' : '$value',
        style: GoogleFonts.cairo(
          color: value > 0 ? AppColors.badgeRed : AppColors.primary,
          fontSize: 17,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
    );
  }
}
