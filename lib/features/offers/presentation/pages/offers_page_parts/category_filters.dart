part of '../offers_page.dart';

class _CategoryFilters extends StatelessWidget {
  final List<String> categories;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _CategoryFilters({
    required this.categories,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      height: 62,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 2),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;

          return InkWell(
            onTap: () => onChanged(index),
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? AppColors.primary : theme.dividerColor,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isSelected ? AppColors.primary : Colors.black)
                        .withOpacity(isSelected ? 0.18 : 0.04),
                    blurRadius: isSelected ? 18 : 10,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: Text(
                categories[index],
                style: GoogleFonts.cairo(
                  color: isSelected
                      ? Colors.white
                      : colorScheme.onSurfaceVariant,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
