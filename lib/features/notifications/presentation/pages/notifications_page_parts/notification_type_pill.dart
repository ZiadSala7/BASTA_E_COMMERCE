part of '../notifications_page.dart';

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
