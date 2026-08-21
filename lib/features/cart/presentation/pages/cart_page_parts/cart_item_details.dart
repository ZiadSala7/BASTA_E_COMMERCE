part of '../cart_page.dart';

class _CartItemDetails extends StatelessWidget {
  const _CartItemDetails({required this.item});

  final _CartProduct item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final attributeLabels = <String>[];
    if (item.attributes != null) {
      for (final entry in item.attributes!.entries) {
        if (entry.value != null && entry.value.toString().trim().isNotEmpty) {
          attributeLabels.add('${entry.key}: ${entry.value}');
        }
      }
    } else {
      if (item.size != null && item.size!.isNotEmpty) {
        attributeLabels.add(item.size!);
      }
      if (item.color != null && item.color!.isNotEmpty) {
        attributeLabels.add(item.color!);
      }
      if (item.weightInKg != null && item.weightInKg!.isNotEmpty) {
        attributeLabels.add('${item.weightInKg} kg');
      }
    }

    final hasDiscount =
        item.compareAtPrice != null && item.compareAtPrice! > item.unitPrice;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (item.storeName.trim().isNotEmpty)
          Row(
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: item.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Icon(
                  Icons.storefront_rounded,
                  color: item.accent,
                  size: 11,
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  item.storeName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
              ),
            ],
          ),
        Text(
          item.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.cairo(
            color: colorScheme.onSurface,
            fontSize: 13.5,
            fontWeight: FontWeight.w900,
            height: 1.2,
          ),
        ),
        if (attributeLabels.isNotEmpty)
          Wrap(
            spacing: 4,
            runSpacing: 2,
            children: attributeLabels.take(2).map((attr) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  attr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              );
            }).toList(),
          ),
        if (item.stockQuantity > 0 && item.stockQuantity <= 5)
          Text(
            l10n.pick(
              ar: 'بقي ${item.stockQuantity} فقط في المخزون',
              en: 'Only ${item.stockQuantity} left in stock',
            ),
            style: GoogleFonts.cairo(
              color: const Color(0xFFE53935),
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              _money(item.unitPrice),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.cairo(
                color: AppColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
            if (hasDiscount) ...[
              const SizedBox(width: 6),
              Text(
                _money(item.compareAtPrice!),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.cairo(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.75),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.lineThrough,
                  decorationColor: const Color(0xFFE53935).withValues(alpha: 0.75),
                  decorationThickness: 1.5,
                  height: 1,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
