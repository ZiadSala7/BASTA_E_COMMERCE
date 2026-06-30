part of '../notifications_page.dart';

class _NotificationTile extends StatelessWidget {
  final AppNotificationEntity data;
  final bool isUpdating;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.data,
    required this.isUpdating,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final rowDirection = l10n.isArabic ? TextDirection.rtl : TextDirection.ltr;
    final accent = _accentForType(data.type);
    final unread = !data.isRead;

    return InkWell(
      onTap: isUpdating ? null : onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: unread
                ? accent.withOpacity(0.34)
                : colorScheme.outlineVariant.withOpacity(0.7),
          ),
        ),
        child: Row(
          textDirection: rowDirection,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StatusBadge(type: data.type),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: l10n.isArabic
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Row(
                    textDirection: rowDirection,
                    children: [
                      Expanded(
                        child: Text(
                          data.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: l10n.isArabic
                              ? TextAlign.right
                              : TextAlign.left,
                          style: GoogleFonts.cairo(
                            color: colorScheme.onSurface,
                            fontSize: 15.5,
                            fontWeight: unread
                                ? FontWeight.w900
                                : FontWeight.w700,
                            height: 1.15,
                          ),
                        ),
                      ),
                      if (unread) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 7),
                  Text(
                    data.message,
                    textAlign: l10n.isArabic ? TextAlign.right : TextAlign.left,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    textDirection: rowDirection,
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _relativeTime(context, data.createdAt),
                        style: GoogleFonts.cairo(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      if (isUpdating)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        _NotificationTypePill(type: data.type),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
