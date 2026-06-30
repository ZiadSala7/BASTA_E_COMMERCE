part of '../products_listing_page.dart';

class _ActiveFiltersBar extends StatelessWidget {
  final String sortBy;
  final ValueChanged<String> onSortChanged;
  final VoidCallback onClearFilters;

  const _ActiveFiltersBar({
    required this.sortBy,
    required this.onSortChanged,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
      ),
      child: Row(
        children: [
          Text(
            l10n.pick(ar: 'الترتيب', en: 'Sort'),
            style: GoogleFonts.cairo(
              color: colorScheme.onSurfaceVariant,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.42,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: sortBy,
                dropdownColor: colorScheme.surface,
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  color: colorScheme.onSurface,
                ),
                onChanged: (value) {
                  if (value != null) onSortChanged(value);
                },
                items: ['newest', 'price_low', 'price_high', 'sale'].map((
                  value,
                ) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      _getSortLabel(value, l10n),
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: onClearFilters,
            child: Text(
              l10n.pick(ar: 'مسح الفلاتر', en: 'Clear Filters'),
              style: GoogleFonts.cairo(fontSize: 13, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  String _getSortLabel(String sortValue, AppLocalizations l10n) {
    switch (sortValue) {
      case 'newest':
        return l10n.pick(ar: 'الأحدث', en: 'Newest');
      case 'price_low':
        return l10n.pick(
          ar: 'السعر: من الأقل للأعلى',
          en: 'Price: Low to High',
        );
      case 'price_high':
        return l10n.pick(
          ar: 'السعر: من الأعلى للأقل',
          en: 'Price: High to Low',
        );
      case 'sale':
        return l10n.pick(ar: 'أفضل العروض', en: 'Best Sale');
      default:
        return l10n.pick(ar: 'ترتيب حسب', en: 'Sort By');
    }
  }
}
