// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;

import '../../../../core/extensions/app_localizations_x.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/widgets/common/section_header.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/home_category_entity.dart';

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

class _CategoryData {
  final String label;
  final String description;
  final IconData icon;
  final Color accent;
  final HomeCategoryEntity? category;

  const _CategoryData({
    required this.label,
    required this.description,
    required this.icon,
    required this.accent,
    this.category,
  });
}

class _CategoryTile extends StatelessWidget {
  final _CategoryData data;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.data,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      selected: isSelected,
      label: data.label,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          width: 132,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected
                  ? data.accent.withOpacity(0.56)
                  : colorScheme.outlineVariant.withOpacity(0.7),
              width: isSelected ? 1.4 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: (isSelected ? data.accent : Colors.black).withOpacity(
                  isSelected ? 0.18 : 0.055,
                ),
                blurRadius: isSelected ? 22 : 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _CategoryVisual(data: data),
                  const Spacer(),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? data.accent
                          : colorScheme.surfaceContainerHighest.withOpacity(
                              0.65,
                            ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isSelected
                          ? Icons.check_rounded
                          : Icons.arrow_forward_rounded,
                      color: isSelected
                          ? Colors.white
                          : colorScheme.onSurfaceVariant,
                      size: 15,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                data.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.cairo(
                  color: colorScheme.onSurface,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w900,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                data.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.cairo(
                  color: isSelected
                      ? data.accent
                      : colorScheme.onSurfaceVariant,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryVisual extends StatelessWidget {
  const _CategoryVisual({required this.data});

  final _CategoryData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: data.accent.withOpacity(0.11),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: data.accent.withOpacity(0.18)),
      ),
      child: Icon(data.icon, color: data.accent, size: 25),
    );
  }
}
