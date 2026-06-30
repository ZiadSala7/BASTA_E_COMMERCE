part of '../cart_page.dart';

class _VendorCartSection extends StatelessWidget {
  const _VendorCartSection({
    required this.group,
    required this.updatingItemIds,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
    required this.onFavoriteTap,
  });

  final _VendorCartGroup group;
  final Set<String> updatingItemIds;
  final ValueChanged<int> onIncrement;
  final ValueChanged<int> onDecrement;
  final Future<bool> Function(int index) onRemove;
  final ValueChanged<int> onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (group.hasStoreName) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.storefront_rounded,
                    color: AppColors.primary,
                    size: 19,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    group.storeName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      color: colorScheme.onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  _money(group.subtotal),
                  style: GoogleFonts.cairo(
                    color: AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              l10n.pick(
                ar: '${group.items.length} Ù…Ù†ØªØ¬',
                en: '${group.items.length} products',
              ),
              style: GoogleFonts.cairo(
                color: colorScheme.onSurfaceVariant,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
        for (var index = 0; index < group.items.length; index++) ...[
          _CartItemCard(
            item: group.items[index].item,
            isUpdating: updatingItemIds.contains(group.items[index].item.id),
            onIncrement: () => onIncrement(group.items[index].index),
            onDecrement: () => onDecrement(group.items[index].index),
            onRemove: () => onRemove(group.items[index].index),
            onFavoriteTap: () => onFavoriteTap(group.items[index].index),
          ),
          if (index != group.items.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}
