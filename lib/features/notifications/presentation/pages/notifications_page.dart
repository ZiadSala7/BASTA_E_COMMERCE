// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/extensions/app_localizations_x.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../l10n/app_localizations.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _showUnread = true;

  List<_NotificationData> _notifications(AppLocalizations l10n) => [
    _NotificationData(
      title: l10n.discountOffer,
      body: l10n.notificationDiscountBody,
      status: _NotificationStatus.success,
      accent: AppColors.accentGreen,
      icon: Icons.local_offer_outlined,
      isUnread: true,
    ),
    _NotificationData(
      title: l10n.specialOfferForYou,
      body: l10n.notificationSpecialOfferBody,
      status: _NotificationStatus.alert,
      accent: AppColors.accent,
      icon: Icons.flash_on_rounded,
      isUnread: true,
    ),
    _NotificationData(
      title: l10n.discountOffer,
      body: l10n.notificationDiscountBody,
      status: _NotificationStatus.success,
      accent: AppColors.primary,
      icon: Icons.percent_rounded,
      isUnread: false,
    ),
    _NotificationData(
      title: l10n.orderReceived,
      body: l10n.notificationOrderReceivedBody,
      status: _NotificationStatus.success,
      accent: const Color(0xFF0EA5E9),
      icon: Icons.inventory_2_outlined,
      isUnread: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final notifications = _notifications(l10n);
    final visibleNotifications = notifications
        .where((item) => _showUnread ? item.isUnread : !item.isUnread)
        .toList();

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
        showNotificationButton: true,
        showBackButton: true,
        onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
        onNotificationPressed: null,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 26),
        children: [
          _NotificationOverview(
            totalCount: notifications.length,
            unreadCount: notifications.where((item) => item.isUnread).length,
          ),
          const SizedBox(height: 14),
          _ReadStateTabs(
            showUnread: _showUnread,
            unreadCount: notifications.where((item) => item.isUnread).length,
            readCount: notifications.where((item) => !item.isUnread).length,
            onChanged: (value) => setState(() => _showUnread = value),
          ),
          const SizedBox(height: 20),
          _NotificationsHeader(
            title: _showUnread ? l10n.unread : l10n.read,
            actionLabel: l10n.clearAll,
          ),
          const SizedBox(height: 10),
          _NotificationsList(notifications: visibleNotifications),
        ],
      ),
    );
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
  });

  final int totalCount;
  final int unreadCount;

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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
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
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.22),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
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
                  l10n.pick(ar: 'مركز الإشعارات', en: 'Notification center'),
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
    );
  }
}

class _OverviewBadge extends StatelessWidget {
  const _OverviewBadge({required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.badgeRed.withOpacity(0.10),
        shape: BoxShape.circle,
      ),
      child: Text(
        '$value',
        style: GoogleFonts.cairo(
          color: AppColors.badgeRed,
          fontSize: 17,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
    );
  }
}

class _ReadStateTabs extends StatelessWidget {
  final bool showUnread;
  final int unreadCount;
  final int readCount;
  final ValueChanged<bool> onChanged;

  const _ReadStateTabs({
    required this.showUnread,
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
              label: l10n.unread,
              count: unreadCount,
              isSelected: showUnread,
              onTap: () => onChanged(true),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _ReadStateTab(
              label: l10n.read,
              count: readCount,
              isSelected: !showUnread,
              onTap: () => onChanged(false),
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
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.20),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
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
                '$count',
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
  const _NotificationsHeader({required this.title, required this.actionLabel});

  final String title;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: Column(
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
                l10n.today,
                style: GoogleFonts.cairo(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        TextButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.done_all_rounded, size: 17),
          label: Text(actionLabel),
        ),
      ],
    );
  }
}

class _NotificationsList extends StatelessWidget {
  final List<_NotificationData> notifications;

  const _NotificationsList({required this.notifications});

  @override
  Widget build(BuildContext context) {
    if (notifications.isEmpty) {
      return const _NotificationsEmptyState();
    }

    return Column(
      children: [
        for (var index = 0; index < notifications.length; index++) ...[
          _NotificationTile(data: notifications[index], index: index),
          if (index != notifications.length - 1) const SizedBox(height: 12),
        ],
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
  final _NotificationData data;
  final int index;

  const _NotificationTile({required this.data, required this.index});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final rowDirection = l10n.isArabic ? TextDirection.rtl : TextDirection.ltr;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: data.isUnread
              ? data.accent.withOpacity(0.34)
              : colorScheme.outlineVariant.withOpacity(0.7),
        ),
        boxShadow: [
          BoxShadow(
            color: (data.isUnread ? data.accent : Colors.black).withOpacity(
              data.isUnread ? 0.11 : 0.045,
            ),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        textDirection: rowDirection,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StatusBadge(data: data),
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
                          fontWeight: FontWeight.w900,
                          height: 1.15,
                        ),
                      ),
                    ),
                    if (data.isUnread) ...[
                      const SizedBox(width: 8),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: data.accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 7),
                Text(
                  data.body,
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
                      index == 0 ? l10n.oneHourAgo : l10n.hoursAgo(index + 1),
                      style: GoogleFonts.cairo(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    _NotificationStatusPill(data: data),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final _NotificationData data;

  const _StatusBadge({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: data.accent.withOpacity(0.12),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(data.icon, color: data.accent, size: 23),
    );
  }
}

class _NotificationStatusPill extends StatelessWidget {
  const _NotificationStatusPill({required this.data});

  final _NotificationData data;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: data.accent.withOpacity(0.11),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        data.status == _NotificationStatus.success
            ? l10n.pick(ar: 'مهم', en: 'Important')
            : l10n.pick(ar: 'تنبيه', en: 'Alert'),
        style: GoogleFonts.cairo(
          color: data.accent,
          fontSize: 10.5,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
    );
  }
}

class _NotificationData {
  final String title;
  final String body;
  final _NotificationStatus status;
  final Color accent;
  final IconData icon;
  final bool isUnread;

  const _NotificationData({
    required this.title,
    required this.body,
    required this.status,
    required this.accent,
    required this.icon,
    required this.isUnread,
  });
}

enum _NotificationStatus { success, alert }
