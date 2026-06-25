// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/extensions/app_localizations_x.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_router.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/status/empty_state.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/app_notification_entity.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../../domain/services/notifications_controller.dart';

enum _NotificationFilter { all, unread, read }

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  static const _pageLimit = 10;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _scrollController = ScrollController();

  late final NotificationsRepository _repository;
  late final NotificationsController _notificationsController;

  final List<AppNotificationEntity> _notifications = <AppNotificationEntity>[];
  final Set<String> _markingReadIds = <String>{};
  _NotificationFilter _filter = _NotificationFilter.all;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _isMarkingAllRead = false;
  bool _hasMore = true;
  int _page = 1;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _repository = sl<NotificationsRepository>();
    _notificationsController = sl<NotificationsController>();
    _scrollController.addListener(_onScroll);
    _loadNotifications(refresh: true);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final unreadCount = _notifications.where((item) => !item.isRead).length;
    final readCount = _notifications.length - unreadCount;
    final visibleNotifications = _filteredNotifications();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: const AppDrawer(),
      appBar: CustomAppBar(
        titleWidget: _NotificationsAppBarTitle(
          title: l10n.notifications,
          subtitle: l10n.pick(
            ar: 'تنبيهاتك وآخر التحديثات',
            en: 'Alerts and updates',
          ),
        ),
        showSearch: false,
        showLogo: false,
        showMenuButton: false,
        showNotificationButton: false,
        showBackButton: true,
        onNotificationPressed: () => context.pop(),
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadNotifications(refresh: true),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
            ? ListView(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 26),
                children: [
                  EmptyState(
                    icon: Icons.notifications_off_outlined,
                    title: l10n.pick(
                      ar: 'تعذر تحميل الإشعارات',
                      en: 'Could not load notifications',
                    ),
                    message: _errorMessage,
                    actionLabel: l10n.tryAgain,
                    onActionTap: () => _loadNotifications(refresh: true),
                  ),
                ],
              )
            : ListView(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 26),
                children: [
                  _NotificationOverview(
                    totalCount: _notifications.length,
                    unreadCount: unreadCount,
                    isMarkingAllRead: _isMarkingAllRead,
                    onMarkAllRead: unreadCount > 0 ? _markAllAsRead : null,
                  ),
                  const SizedBox(height: 14),
                  _ReadStateTabs(
                    filter: _filter,
                    totalCount: _notifications.length,
                    unreadCount: unreadCount,
                    readCount: readCount,
                    onChanged: (value) => setState(() => _filter = value),
                  ),
                  const SizedBox(height: 20),
                  _NotificationsHeader(
                    title: _filterTitle(l10n),
                    subtitle: _filter == _NotificationFilter.all
                        ? l10n.pick(ar: 'كل الإشعارات', en: 'All notifications')
                        : _showUnread
                        ? l10n.pick(
                            ar: 'الإشعارات الجديدة',
                            en: 'New notifications',
                          )
                        : l10n.pick(
                            ar: 'الإشعارات المقروءة',
                            en: 'Read notifications',
                          ),
                  ),
                  const SizedBox(height: 10),
                  if (visibleNotifications.isEmpty)
                    const _NotificationsEmptyState()
                  else
                    for (
                      var index = 0;
                      index < visibleNotifications.length;
                      index++
                    ) ...[
                      _NotificationTile(
                        data: visibleNotifications[index],
                        isUpdating: _markingReadIds.contains(
                          visibleNotifications[index].id,
                        ),
                        onTap: () =>
                            _openNotification(visibleNotifications[index]),
                      ),
                      if (index != visibleNotifications.length - 1)
                        const SizedBox(height: 12),
                    ],
                  if (_isLoadingMore) ...[
                    const SizedBox(height: 18),
                    const Center(child: CircularProgressIndicator()),
                  ],
                ],
              ),
      ),
    );
  }

  Future<void> _loadNotifications({required bool refresh}) async {
    if (_isLoadingMore) return;

    if (refresh) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _page = 1;
        _hasMore = true;
      });
    } else {
      if (!_hasMore) return;
      setState(() => _isLoadingMore = true);
    }

    try {
      final items = await _repository.getNotifications(
        page: refresh ? 1 : _page + 1,
        limit: _pageLimit,
      );

      if (!mounted) return;
      setState(() {
        if (refresh) {
          _notifications
            ..clear()
            ..addAll(items);
          _page = 1;
        } else {
          _notifications.addAll(items);
          _page++;
        }
        _hasMore = items.length == _pageLimit;
        _isLoading = false;
        _isLoadingMore = false;
      });
      await _notificationsController.refreshUnreadCount();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = _cleanError(error);
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  bool get _showUnread => _filter != _NotificationFilter.read;

  List<AppNotificationEntity> _filteredNotifications() {
    switch (_filter) {
      case _NotificationFilter.unread:
        return _notifications
            .where((item) => !item.isRead)
            .toList(growable: false);
      case _NotificationFilter.read:
        return _notifications
            .where((item) => item.isRead)
            .toList(growable: false);
      case _NotificationFilter.all:
        return List<AppNotificationEntity>.unmodifiable(_notifications);
    }
  }

  String _filterTitle(AppLocalizations l10n) {
    switch (_filter) {
      case _NotificationFilter.unread:
        return l10n.unread;
      case _NotificationFilter.read:
        return l10n.read;
      case _NotificationFilter.all:
        return l10n.all;
    }
  }

  Future<void> _markAllAsRead() async {
    if (_isMarkingAllRead || _isLoading) return;

    final successMessage = AppLocalizations.of(context)!.pick(
      ar: 'تم تحديد كل الإشعارات كمقروءة',
      en: 'All notifications marked as read',
    );

    setState(() => _isMarkingAllRead = true);

    try {
      await _loadRemainingNotificationsForBulkAction();
      if (!mounted) return;

      final unreadItems = _notifications
          .where((item) => !item.isRead && item.id.isNotEmpty)
          .toList(growable: false);
      if (unreadItems.isEmpty) {
        setState(() => _isMarkingAllRead = false);
        return;
      }

      setState(() {
        _markingReadIds.addAll(unreadItems.map((item) => item.id));
        for (final notification in unreadItems) {
          final index = _notifications.indexWhere(
            (item) => item.id == notification.id,
          );
          if (index != -1) {
            _notifications[index] = notification.copyWith(isRead: true);
          }
        }
      });
      _notificationsController.setUnreadCount(0);

      for (final notification in unreadItems) {
        await _repository.markAsRead(notification.id);
      }

      await _notificationsController.refreshUnreadCount();
      if (!mounted) return;
      _showSnackBar(successMessage);
    } catch (error) {
      await _notificationsController.refreshUnreadCount();
      if (!mounted) return;
      _showSnackBar(_cleanError(error));
      await _loadNotifications(refresh: true);
    } finally {
      if (mounted) {
        setState(() {
          _isMarkingAllRead = false;
          _markingReadIds.clear();
        });
      }
    }
  }

  Future<void> _loadRemainingNotificationsForBulkAction() async {
    if (!_hasMore) return;

    var nextPage = _page + 1;
    var hasMore = _hasMore;
    final loadedById = <String, AppNotificationEntity>{
      for (final notification in _notifications) notification.id: notification,
    };

    while (hasMore) {
      final items = await _repository.getNotifications(
        page: nextPage,
        limit: _pageLimit,
      );
      for (final item in items) {
        loadedById[item.id] = item;
      }
      hasMore = items.length == _pageLimit;
      if (hasMore) nextPage++;
    }

    if (!mounted) return;
    setState(() {
      _notifications
        ..clear()
        ..addAll(loadedById.values);
      _page = nextPage;
      _hasMore = false;
      _isLoadingMore = false;
    });
  }

  Future<void> _openNotification(AppNotificationEntity notification) async {
    if (!notification.isRead) {
      final index = _notifications.indexWhere(
        (item) => item.id == notification.id,
      );
      if (index != -1) {
        setState(() {
          _markingReadIds.add(notification.id);
          _notifications[index] = notification.copyWith(isRead: true);
        });
        _notificationsController.decrementUnread();

        try {
          await _repository.markAsRead(notification.id);
        } catch (error) {
          if (mounted) {
            setState(() {
              _notifications[index] = notification;
            });
          }
          _notificationsController.refreshUnreadCount();
          _showSnackBar(_cleanError(error));
        } finally {
          if (mounted) {
            setState(() => _markingReadIds.remove(notification.id));
          }
        }
      }
    }

    await _notificationsController.refreshUnreadCount();
    if (!mounted) return;
    _routeFromNotification(notification);
  }

  void _routeFromNotification(AppNotificationEntity notification) {
    final type = notification.type.toUpperCase();
    final path = notification.link ?? '';

    if (type == 'ORDER') {
      context.push(AppRoutes.orders);
      return;
    }

    if (type == 'PROMOTION') {
      context.push(AppRoutes.products);
      return;
    }

    if (path.contains('/orders')) {
      context.push(AppRoutes.orders);
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _isLoading || _isLoadingMore) return;

    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 160) {
      _loadNotifications(refresh: false);
    }
  }

  String _cleanError(Object error) {
    final message = error.toString();
    return message.startsWith('Exception: ')
        ? message.substring('Exception: '.length)
        : message;
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _NotificationsAppBarTitle extends StatelessWidget {
  const _NotificationsAppBarTitle({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.cairo(
                  color: Colors.white.withOpacity(0.78),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

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

class _ReadStateTab extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  const _ReadStateTab({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: GoogleFonts.cairo(
                color: isSelected ? Colors.white : colorScheme.onSurface,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 7),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.18)
                    : colorScheme.surfaceContainerHighest.withOpacity(0.7),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                count > 99 ? '99+' : '$count',
                style: GoogleFonts.cairo(
                  color: isSelected ? Colors.white : colorScheme.onSurface,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationsHeader extends StatelessWidget {
  const _NotificationsHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.cairo(
            color: colorScheme.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: GoogleFonts.cairo(
            color: colorScheme.onSurfaceVariant,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

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

class _StatusBadge extends StatelessWidget {
  final String type;

  const _StatusBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    final accent = _accentForType(type);
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: accent.withOpacity(0.12),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(_iconForType(type), color: accent, size: 23),
    );
  }
}

class _NotificationTypePill extends StatelessWidget {
  const _NotificationTypePill({required this.type});

  final String type;

  @override
  Widget build(BuildContext context) {
    final accent = _accentForType(type);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.11),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        type.toUpperCase(),
        style: GoogleFonts.cairo(
          color: accent,
          fontSize: 10.5,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
    );
  }
}

Color _accentForType(String type) {
  switch (type.toUpperCase()) {
    case 'ORDER':
      return const Color(0xFF0EA5E9);
    case 'STORE':
      return AppColors.primary;
    case 'PROMOTION':
      return AppColors.accent;
    case 'SYSTEM':
    default:
      return AppColors.accentGreen;
  }
}

IconData _iconForType(String type) {
  switch (type.toUpperCase()) {
    case 'ORDER':
      return Icons.inventory_2_outlined;
    case 'STORE':
      return Icons.storefront_rounded;
    case 'PROMOTION':
      return Icons.local_offer_outlined;
    case 'SYSTEM':
    default:
      return Icons.campaign_outlined;
  }
}

String _relativeTime(BuildContext context, DateTime? date) {
  final l10n = AppLocalizations.of(context)!;
  if (date == null) return l10n.today;

  final diff = DateTime.now().difference(date);
  if (diff.inMinutes < 1) {
    return l10n.pick(ar: 'الآن', en: 'Now');
  }
  if (diff.inMinutes < 60) {
    return l10n.pick(
      ar: 'منذ ${diff.inMinutes} د',
      en: '${diff.inMinutes}m ago',
    );
  }
  if (diff.inHours < 24) {
    return l10n.hoursAgo(diff.inHours);
  }
  if (diff.inDays < 7) {
    return l10n.pick(ar: 'منذ ${diff.inDays} يوم', en: '${diff.inDays}d ago');
  }

  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
