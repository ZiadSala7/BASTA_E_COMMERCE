part of '../notifications_page.dart';

class _NotificationsEmptyState extends StatelessWidget {
  const _NotificationsEmptyState();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.7)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.notifications_none_rounded,
            color: AppColors.primary.withOpacity(0.8),
            size: 38,
          ),
          const SizedBox(height: 10),
          Text(
            l10n.pick(ar: 'لا توجد إشعارات هنا', en: 'No notifications here'),
            style: GoogleFonts.cairo(
              color: colorScheme.onSurface,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
