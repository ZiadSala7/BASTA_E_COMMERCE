part of '../home_page_categories_strip.dart';

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
