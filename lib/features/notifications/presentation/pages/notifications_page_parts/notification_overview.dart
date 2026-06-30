part of '../notifications_page.dart';

class _NotificationOverview extends StatelessWidget {
  const _NotificationOverview({
    required this.totalCount,
    required this.unreadCount,
    required this.isMarkingAllRead,
    required this.onMarkAllRead,
  });

  final int totalCount;
  final int unreadCount;
  final bool isMarkingAllRead;
  final VoidCallback? onMarkAllRead;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.7)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryDark,
                      AppColors.primary,
                      Color(0xFF20B7A8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.notifications_active_outlined,
                  color: Colors.white,
                  size: 25,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.pick(
                        ar: 'مركز الإشعارات',
                        en: 'Notification center',
                      ),
                      style: GoogleFonts.cairo(
                        color: colorScheme.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      l10n.pick(
                        ar: '$unreadCount غير مقروء من $totalCount إشعارات',
                        en: '$unreadCount unread of $totalCount notifications',
                      ),
                      style: GoogleFonts.cairo(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              _OverviewBadge(value: unreadCount),
            ],
          ),
          if (unreadCount > 0) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: isMarkingAllRead ? null : onMarkAllRead,
                icon: isMarkingAllRead
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.done_all_rounded, size: 18),
                label: Text(
                  l10n.pick(ar: 'تحديد الكل كمقروء', en: 'Mark all as read'),
                  style: GoogleFonts.cairo(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
