part of '../home_featured_stores_section.dart';

class HomeFeaturedStoresSection extends StatelessWidget {
  final List<HomeFeaturedStore> stores;
  final VoidCallback? onShowAllTap;
  final ValueChanged<HomeFeaturedStore>? onStoreTap;

  const HomeFeaturedStoresSection({
    super.key,
    required this.stores,
    this.onShowAllTap,
    this.onStoreTap,
  });

  @override
  Widget build(BuildContext context) {
    if (stores.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: .spaceBetween,
            textDirection: l10n.isArabic
                ? TextDirection.rtl
                : TextDirection.ltr,
            children: [
              Expanded(
                child: Text(
                  l10n.featuredStores,
                  style: GoogleFonts.cairo(
                    color: colorScheme.onSurface,
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
              ),
              TextButton(
                onPressed: onShowAllTap ?? () {},
                style: TextButton.styleFrom(
                  foregroundColor: colorScheme.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  minimumSize: const Size(0, 36),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  l10n.showAll,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 116,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            itemCount: stores.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final store = stores[index];
              return _FeaturedStoreCard(
                store: store,
                onTap: onStoreTap == null ? null : () => onStoreTap!(store),
              );
            },
          ),
        ),
      ],
    );
  }
}
