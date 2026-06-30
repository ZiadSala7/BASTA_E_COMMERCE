part of '../home_page.dart';

class _HomeProductsEmptySection extends StatelessWidget {
  final String? categoryName;
  final VoidCallback onBrowseAllTap;

  const _HomeProductsEmptySection({
    required this.categoryName,
    required this.onBrowseAllTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasCategory = categoryName != null && categoryName!.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: colorScheme.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
          child: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.inventory_2_outlined,
                  color: colorScheme.primary,
                  size: 34,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                hasCategory
                    ? l10n.pick(
                        ar: 'لا توجد منتجات في هذا القسم',
                        en: 'No products in this category',
                      )
                    : l10n.pick(
                        ar: 'لا توجد منتجات حالياً',
                        en: 'No products found',
                      ),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                hasCategory
                    ? l10n.pick(
                        ar: 'لم نجد منتجات في $categoryName الآن. يمكنك تصفح كل المنتجات أو تجربة قسم آخر.',
                        en: 'We could not find products in $categoryName right now. Browse all products or try another category.',
                      )
                    : l10n.pick(
                        ar: 'سنضيف منتجات جديدة قريباً. يمكنك تصفح كل المنتجات أو العودة لاحقاً.',
                        en: 'New products will appear here soon. You can browse all products or check back later.',
                      ),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: onBrowseAllTap,
                icon: const Icon(Icons.shopping_bag_outlined, size: 18),
                label: Text(
                  l10n.pick(ar: 'تصفح كل المنتجات', en: 'Browse all products'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
