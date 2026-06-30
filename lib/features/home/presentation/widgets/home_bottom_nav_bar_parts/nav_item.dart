part of '../home_bottom_nav_bar.dart';

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final int? badgeCount;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          height: 58,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withOpacity(
                    theme.brightness == Brightness.dark ? 0.20 : 0.10,
                  )
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    icon,
                    size: 23,
                    color: isSelected
                        ? AppColors.primary
                        : colorScheme.onSurfaceVariant,
                  ),
                  if (badgeCount != null && badgeCount! > 0)
                    PositionedDirectional(
                      top: -5,
                      end: -7,
                      child: Container(
                        constraints: const BoxConstraints(
                          minWidth: 17,
                          minHeight: 17,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        height: 17,
                        decoration: BoxDecoration(
                          color: AppColors.badgeRed,
                          borderRadius: BorderRadius.circular(99),
                          border: Border.all(
                            color: colorScheme.surface,
                            width: 1.4,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            badgeCount! > 99 ? '99+' : '$badgeCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.cairo(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                  color: isSelected
                      ? AppColors.primary
                      : colorScheme.onSurfaceVariant,
                  height: 1.05,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
