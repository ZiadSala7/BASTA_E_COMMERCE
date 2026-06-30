part of '../cart_checkout_page.dart';

class _CheckoutItemTile extends StatelessWidget {
  final CartItemEntity item;

  const _CheckoutItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
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
                'Qty ${item.quantity}',
                style: GoogleFonts.cairo(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          _money(item.activePrice * item.quantity),
          style: GoogleFonts.cairo(
            color: AppColors.primary,
            fontSize: 13.5,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
