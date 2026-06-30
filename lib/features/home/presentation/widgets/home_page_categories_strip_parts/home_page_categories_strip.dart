part of '../home_page_categories_strip.dart';

class HomePageCategoriesStrip extends StatelessWidget {
  final List<HomeCategoryEntity> categories;
  final String? selectedCategorySlug;
  final ValueChanged<HomeCategoryEntity?> onCategorySelected;

  const HomePageCategoriesStrip({
    super.key,
    required this.categories,
    required this.selectedCategorySlug,
    required this.onCategorySelected,
  });

  static const _accents = [
    AppColors.primary,
    Color(0xFFB7791F),
    Color(0xFF0F8D7D),
    Color(0xFFE05D7B),
    Color(0xFF4F6FDE),
    Color(0xFF7C4A2D),
    Color(0xFF7C3AED),
    Color(0xFF2563EB),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tiles = <_CategoryData>[
      _CategoryData(
        label: l10n.showAll,
        description: l10n.pick(ar: 'كل المنتجات', en: 'All products'),
        icon: Icons.grid_view_rounded,
        accent: AppColors.primary,
      ),
      ...categories.indexed.map((entry) {
        final (index, category) = entry;
        return _CategoryData(
          label: category.name,
          description: category.description,
          icon: _iconForSlug(category.slug),
          accent: _accents[(index + 1) % _accents.length],
          category: category,
        );
      }),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Directionality(
          textDirection: l10n.isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: SectionHeader(
            title: l10n.pick(ar: 'تصفح الأقسام', en: 'Browse categories'),
            subtitle: l10n.pick(
              ar: 'اختيارات منظمة للوصول الأسرع',
              en: 'Curated shortcuts for faster shopping',
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 132,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: tiles.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final data = tiles[index];
              final slug = data.category?.slug;

              return _CategoryTile(
                data: data,
                isSelected: slug == selectedCategorySlug,
                onTap: () => onCategorySelected(data.category),
              );
            },
          ),
        ),
      ],
    );
  }

  IconData _iconForSlug(String slug) {
    if (slug.contains('electronics') || slug.contains('gaming')) {
      return Icons.devices_rounded;
    }
    if (slug.contains('clothing') || slug.contains('clothes')) {
      return Icons.checkroom_rounded;
    }
    if (slug.contains('food') || slug.contains('sweets')) {
      return Icons.local_dining_rounded;
    }
    if (slug.contains('coffee') || slug.contains('spices')) {
      return Icons.coffee_rounded;
    }
    if (slug.contains('jewelry')) return Icons.diamond_rounded;
    if (slug.contains('shoes')) return Icons.hiking_rounded;
    if (slug.contains('equipment')) return Icons.sports_soccer_rounded;
    return Icons.category_rounded;
  }
}
