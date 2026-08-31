part of '../account_stats_panel.dart';

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
              onTap: () => context.push(AppRoutes.coupons),
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
