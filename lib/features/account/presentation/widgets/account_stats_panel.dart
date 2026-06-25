// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/extensions/app_localizations_x.dart';
import '../../../../core/utils/app_router.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/account_stats_entity.dart';

class AccountStatsPanel extends StatelessWidget {
  final AccountStatsEntity? stats;

  const AccountStatsPanel({super.key, this.stats});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
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
          Expanded(
            child: _AccountStat(
              icon: Icons.inventory_2_outlined,
              label: l10n.myOrders,
              value: '${stats?.ordersCount ?? 0}',
              onTap: () => context.push(AppRoutes.orders),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _AccountStat(
              icon: Icons.local_offer_outlined,
              label: l10n.coupons,
              value: '${stats?.couponsCount ?? 0}',
              onTap: () => _showComingSoon(context, l10n.coupons),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _AccountStat(
              icon: Icons.favorite_border_rounded,
              label: l10n.favorites,
              value: '${stats?.favoritesCount ?? 0}',
              onTap: () => context.push(AppRoutes.favorites),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountStat extends StatelessWidget {
  const _AccountStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: AppColors.primary.withOpacity(0.08),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 86,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Column(
            children: [
              Icon(icon, color: AppColors.primary, size: 21),
              const SizedBox(height: 7),
              Text(
                value,
                style: GoogleFonts.cairo(
                  color: colorScheme.onSurface,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.cairo(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _showComingSoon(BuildContext context, String featureName) {
  final l10n = AppLocalizations.of(context)!;

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          l10n.pick(
            ar: '$featureName ستكون متاحة قريباً',
            en: '$featureName will be available soon',
          ),
        ),
      ),
    );
}
