part of '../cart_page.dart';

class _CartItemDetails extends StatelessWidget {
  const _CartItemDetails({required this.item});

  final _CartProduct item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return SizedBox(
      height: 112,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.storeName.trim().isNotEmpty) ...[
            Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: item.accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.storefront_rounded,
                    color: item.accent,
                    size: 13,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item.storeName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          Text(
            item.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.cairo(
              color: colorScheme.onSurface,
              fontSize: 14.5,
              fontWeight: FontWeight.w900,
              height: 1.22,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.flash_on_rounded, color: item.accent, size: 14),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  l10n.pick(ar: 'تسليم سريع وآمن', en: 'Fast secure delivery'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            item.price,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.cairo(
              color: AppColors.primary,
              fontSize: 16,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
