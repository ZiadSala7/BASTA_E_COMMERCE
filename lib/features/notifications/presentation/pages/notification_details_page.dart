import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/extensions/app_localizations_x.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_router.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/app_notification_entity.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../../domain/services/notifications_controller.dart';

class NotificationDetailsPage extends StatefulWidget {
  final AppNotificationEntity notification;

  const NotificationDetailsPage({
    super.key,
    required this.notification,
  });

  @override
  State<NotificationDetailsPage> createState() => _NotificationDetailsPageState();
}

class _NotificationDetailsPageState extends State<NotificationDetailsPage> {
  late AppNotificationEntity _notification;

  @override
  void initState() {
    super.initState();
    _notification = widget.notification;
    _markReadIfNeeded();
  }

  Future<void> _markReadIfNeeded() async {
    if (!_notification.isRead) {
      setState(() {
        _notification = _notification.copyWith(isRead: true);
      });
      try {
        if (sl.isRegistered<NotificationsRepository>()) {
          await sl<NotificationsRepository>().markAsRead(_notification.id);
        }
        if (sl.isRegistered<NotificationsController>()) {
          sl<NotificationsController>().decrementUnread();
          await sl<NotificationsController>().refreshUnreadCount();
        }
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accent = _accentForNotificationType(_notification.type);
    final icon = _iconForNotificationType(_notification.type);

    return Directionality(
      textDirection: l10n.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: CustomAppBar(
          title: l10n.pick(ar: 'تفاصيل الإشعار', en: 'Notification Details'),
          showSearch: false,
          showNotificationButton: false,
          showBackButton: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Hero Category & Icon Card ──────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accent.withValues(alpha: 0.14),
                      colorScheme.surface,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: accent.withValues(alpha: 0.28),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Pulsing Glow Icon Container
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            accent,
                            accent.withValues(alpha: 0.78),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: accent.withValues(alpha: 0.35),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(icon, color: Colors.white, size: 38),
                    ),
                    const SizedBox(height: 16),
                    // Type Badge & Time
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: accent.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            _typeLabel(l10n, _notification.type),
                            style: GoogleFonts.cairo(
                              color: accent,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.schedule_rounded,
                                size: 13,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _relativeTime(context, _notification.createdAt),
                                style: GoogleFonts.cairo(
                                  color: colorScheme.onSurfaceVariant,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Main Content Card ──────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.65),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    SelectableText(
                      _notification.title,
                      style: GoogleFonts.cairo(
                        color: colorScheme.onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Divider(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                    const SizedBox(height: 14),
                    // Body text
                    SelectableText(
                      _notification.message,
                      style: GoogleFonts.cairo(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        height: 1.7,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Quick Copy Action
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: TextButton.icon(
                        onPressed: () => _copyMessage(context),
                        icon: const Icon(Icons.copy_rounded, size: 16),
                        label: Text(
                          l10n.pick(ar: 'نسخ النص', en: 'Copy text'),
                          style: GoogleFonts.cairo(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Metadata Section ───────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: Column(
                  children: [
                    _buildMetaRow(
                      context,
                      icon: Icons.mark_email_read_outlined,
                      label: l10n.pick(ar: 'حالة القراءة', en: 'Status'),
                      value: _notification.isRead
                          ? l10n.pick(ar: 'مقروء ✓', en: 'Read ✓')
                          : l10n.pick(ar: 'جديد', en: 'New'),
                      valueColor: _notification.isRead
                          ? AppColors.accentGreen
                          : AppColors.badgeRed,
                    ),
                    if (_notification.createdAt != null) ...[
                      const Divider(height: 18),
                      _buildMetaRow(
                        context,
                        icon: Icons.calendar_today_outlined,
                        label: l10n.pick(ar: 'تاريخ الإشعار', en: 'Date & Time'),
                        value: _formatFullDate(_notification.createdAt!),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Call to Action Button ─────────────────────────────────
              _buildActionButton(context, l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetaRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.cairo(
            color: colorScheme.onSurfaceVariant,
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.cairo(
            color: valueColor ?? colorScheme.onSurface,
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, AppLocalizations l10n) {
    final type = _notification.type.toUpperCase();
    final link = _notification.link ?? '';

    String buttonText;
    IconData buttonIcon;
    VoidCallback onAction;

    if (type == 'ORDER' || link.contains('/orders')) {
      buttonText = l10n.pick(ar: 'الانتقال إلى طلباتي 📦', en: 'View My Orders 📦');
      buttonIcon = Icons.inventory_2_outlined;
      onAction = () => context.push(AppRoutes.orders);
    } else if (type == 'COUPON' ||
        type == 'COUPONS' ||
        type == 'REWARD' ||
        type == 'REWARDS' ||
        type == 'REFERRAL' ||
        link.contains('coupon')) {
      buttonText = l10n.pick(ar: 'عرض قسائمي ومكافآتي 🎁', en: 'View My Coupons 🎁');
      buttonIcon = Icons.card_giftcard_rounded;
      onAction = () => context.push(AppRoutes.coupons);
    } else if (type == 'STORE' || link.contains('/store')) {
      buttonText = l10n.pick(ar: 'تصفح المتاجر 🏪', en: 'Explore Stores 🏪');
      buttonIcon = Icons.storefront_rounded;
      onAction = () => context.push(AppRoutes.stores);
    } else if (type == 'PROMOTION' || link.contains('/product')) {
      buttonText = l10n.pick(ar: 'تصفح المنتجات والعروض 🛍️', en: 'Shop Offers & Products 🛍️');
      buttonIcon = Icons.shopping_bag_outlined;
      onAction = () => context.push(AppRoutes.products);
    } else {
      buttonText = l10n.pick(ar: 'العودة للإشعارات', en: 'Back to Notifications');
      buttonIcon = Icons.arrow_back_rounded;
      onAction = () => Navigator.of(context).maybePop();
    }

    return ElevatedButton.icon(
      onPressed: onAction,
      icon: Icon(buttonIcon, size: 20),
      label: Text(buttonText),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: GoogleFonts.cairo(
          fontSize: 15,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Future<void> _copyMessage(BuildContext context) async {
    final fullText = '${_notification.title}\n\n${_notification.message}';
    await Clipboard.setData(ClipboardData(text: fullText));
    if (!mounted) return;

    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            l10n.pick(ar: 'تم نسخ نص الإشعار بنجاح ✓', en: 'Notification text copied ✓'),
            style: GoogleFonts.cairo(),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  String _typeLabel(AppLocalizations l10n, String type) {
    switch (type.toUpperCase()) {
      case 'ORDER':
        return l10n.pick(ar: 'تحديث طلب', en: 'Order Update');
      case 'COUPON':
      case 'COUPONS':
      case 'REWARD':
      case 'REWARDS':
      case 'REFERRAL':
        return l10n.pick(ar: 'مكافأة وكوبون', en: 'Reward & Coupon');
      case 'STORE':
        return l10n.pick(ar: 'تحديث متجر', en: 'Store Update');
      case 'PROMOTION':
        return l10n.pick(ar: 'عرض ترويجي', en: 'Special Promotion');
      case 'SYSTEM':
      default:
        return l10n.pick(ar: 'تنبيه نظام', en: 'System Alert');
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

  String _formatFullDate(DateTime date) {
    final local = date.toLocal();
    final hour = local.hour > 12
        ? local.hour - 12
        : (local.hour == 0 ? 12 : local.hour);
    final period = local.hour >= 12 ? 'م' : 'ص';
    final minute = local.minute.toString().padLeft(2, '0');
    return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')} $hour:$minute $period';
  }
}

Color _accentForNotificationType(String type) {
  switch (type.toUpperCase()) {
    case 'COUPON':
    case 'COUPONS':
    case 'REWARD':
    case 'REWARDS':
    case 'REFERRAL':
      return const Color(0xFF10B981);
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

IconData _iconForNotificationType(String type) {
  switch (type.toUpperCase()) {
    case 'COUPON':
    case 'COUPONS':
    case 'REWARD':
    case 'REWARDS':
    case 'REFERRAL':
      return Icons.card_giftcard_rounded;
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
