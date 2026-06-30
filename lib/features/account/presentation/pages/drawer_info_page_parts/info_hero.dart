part of '../drawer_info_page.dart';

class _InfoHero extends StatelessWidget {
  const _InfoHero({required this.content});

  final _DrawerInfoContent content;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(content.icon, color: AppColors.primary, size: 30),
          ),
          const SizedBox(height: 14),
          Text(
            content.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: colorScheme.onSurface,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content.subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 14,
              height: 1.65,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
