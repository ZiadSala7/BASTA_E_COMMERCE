part of '../notifications_page.dart';

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
    context.push(
      AppRoutes.notificationDetails,
      extra: notification.copyWith(isRead: true),
    );
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
