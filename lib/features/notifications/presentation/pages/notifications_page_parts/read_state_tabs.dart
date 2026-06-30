part of '../notifications_page.dart';

class _ReadStateTabs extends StatelessWidget {
  final _NotificationFilter filter;
  final int totalCount;
  final int unreadCount;
  final int readCount;
  final ValueChanged<_NotificationFilter> onChanged;

  const _ReadStateTabs({
    required this.filter,
    required this.totalCount,
    required this.unreadCount,
    required this.readCount,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      height: 52,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.7)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ReadStateTab(
              label: l10n.all,
              count: totalCount,
              isSelected: filter == _NotificationFilter.all,
              onTap: () => onChanged(_NotificationFilter.all),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _ReadStateTab(
              label: l10n.unread,
              count: unreadCount,
              isSelected: filter == _NotificationFilter.unread,
              onTap: () => onChanged(_NotificationFilter.unread),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _ReadStateTab(
              label: l10n.read,
              count: readCount,
              isSelected: filter == _NotificationFilter.read,
              onTap: () => onChanged(_NotificationFilter.read),
            ),
          ),
        ],
      ),
    );
  }
}
