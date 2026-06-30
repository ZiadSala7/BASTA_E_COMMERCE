part of '../cart_checkout_page.dart';

class _StoreOrderSection extends StatelessWidget {
  final String storeName;
  final List<CartItemEntity> items;

  const _StoreOrderSection({required this.storeName, required this.items});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (storeName.trim().isNotEmpty) ...[
            Row(
              children: [
                const Icon(
                  Icons.storefront_rounded,
                  color: AppColors.primary,
                  size: 19,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    storeName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      color: colorScheme.onSurface,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Text(
                  _money(_storeTotal),
                  style: GoogleFonts.cairo(
                    color: AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
          for (var index = 0; index < items.length; index++) ...[
            _CheckoutItemTile(item: items[index]),
            if (index != items.length - 1) const Divider(height: 18),
          ],
        ],
      ),
    );
  }

  double get _storeTotal => items.fold<double>(
    0,
    (total, item) => total + (item.activePrice * item.quantity),
  );
}
