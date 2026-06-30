part of '../cart_page.dart';

class _ReadinessChip extends StatelessWidget {
  const _ReadinessChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 68,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withOpacity(0.42),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 17, color: AppColors.primary),
            const SizedBox(height: 7),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.cairo(
                color: colorScheme.onSurfaceVariant,
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                height: 1.1,
              ),
            ),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.cairo(
                color: colorScheme.onSurface,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                height: 1.15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
