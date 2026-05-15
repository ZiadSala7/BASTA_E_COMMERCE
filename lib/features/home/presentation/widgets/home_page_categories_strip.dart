// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;

import '../../../../core/extensions/app_localizations_x.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/widgets/common/section_header.dart';
import '../../../../l10n/app_localizations.dart';

class HomePageCategoriesStrip extends StatefulWidget {
  const HomePageCategoriesStrip({super.key});

  @override
  State<HomePageCategoriesStrip> createState() =>
      _HomePageCategoriesStripState();
}

class _HomePageCategoriesStripState extends State<HomePageCategoriesStrip> {
  int _selectedIndex = 0;

  static const List<_CategoryData> _categories = [
    _CategoryData(
      label: '',
      icon: Icons.grid_view_rounded,
      accent: AppColors.primary,
      count: 128,
    ),
    _CategoryData(
      label: '',
      imageUrl:
          'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?auto=format&fit=crop&w=240&q=85',
      accent: Color(0xFFB7791F),
      count: 34,
    ),
    _CategoryData(
      label: '',
      imageUrl:
          'https://images.unsplash.com/photo-1511920170033-f8396924c348?auto=format&fit=crop&w=240&q=85',
      accent: Color(0xFF7C4A2D),
      count: 21,
    ),
    _CategoryData(
      label: '',
      imageUrl:
          'https://images.unsplash.com/photo-1608571423902-eed4a5ad8108?auto=format&fit=crop&w=240&q=85',
      accent: Color(0xFF0F8D7D),
      count: 18,
    ),
    _CategoryData(
      label: '',
      imageUrl:
          'https://images.unsplash.com/photo-1592945403244-b3fbafd7f539?auto=format&fit=crop&w=240&q=85',
      accent: Color(0xFFE05D7B),
      count: 42,
    ),
    _CategoryData(
      label: '',
      imageUrl:
          'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?auto=format&fit=crop&w=240&q=85',
      accent: Color(0xFF4F6FDE),
      count: 55,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
            itemCount: _categories.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return _CategoryTile(
                data: _categories[index],
                index: index,
                isSelected: index == _selectedIndex,
                onTap: () => setState(() => _selectedIndex = index),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CategoryData {
  final String label;
  final String? imageUrl;
  final IconData? icon;
  final Color accent;
  final int count;

  const _CategoryData({
    required this.label,
    required this.accent,
    required this.count,
    this.imageUrl,
    this.icon,
  });
}

class _CategoryTile extends StatelessWidget {
  final _CategoryData data;
  final int index;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.data,
    required this.index,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final label = _localizedLabel(l10n);

    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          width: 118,
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
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.cairo(
                  color: colorScheme.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                l10n.pick(
                  ar: '${data.count} منتج',
                  en: '${data.count} products',
                ),
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

  String _localizedLabel(AppLocalizations l10n) {
    return switch (index) {
      0 => l10n.showAll,
      1 => l10n.jewelry,
      2 => l10n.coffee,
      3 => l10n.oud,
      4 => l10n.perfumes,
      5 => l10n.fashion,
      _ => data.label,
    };
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
      clipBehavior: Clip.antiAlias,
      child: data.imageUrl == null
          ? Icon(data.icon, color: data.accent, size: 25)
          : Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  data.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Icon(
                    Icons.category_rounded,
                    color: data.accent,
                    size: 24,
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        data.accent.withOpacity(0.22),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
