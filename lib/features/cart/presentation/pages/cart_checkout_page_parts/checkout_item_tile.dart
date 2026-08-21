part of '../cart_checkout_page.dart';

class _CheckoutItemTile extends StatelessWidget {
  final CartItemEntity item;
  final bool hasStockIssue;

  const _CheckoutItemTile({required this.item, required this.hasStockIssue});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: hasStockIssue
            ? const Color(0xFFE53935).withValues(alpha: 0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: hasStockIssue
            ? Border.all(color: const Color(0xFFE53935).withValues(alpha: 0.35))
            : null,
      ),
      child: Padding(
        padding: EdgeInsets.all(hasStockIssue ? 8 : 0),
        child: Row(
          children: [
            _ProductThumb(imageUrl: item.imageUrl),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      color: colorScheme.onSurface,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    hasStockIssue ? 'Out of stock' : 'Qty ${item.quantity}',
                    style: GoogleFonts.cairo(
                      color: hasStockIssue
                          ? const Color(0xFFE53935)
                          : colorScheme.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              _money(item.activePrice * item.quantity),
              style: GoogleFonts.cairo(
                color: hasStockIssue
                    ? const Color(0xFFE53935)
                    : AppColors.primary,
                fontSize: 13.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
