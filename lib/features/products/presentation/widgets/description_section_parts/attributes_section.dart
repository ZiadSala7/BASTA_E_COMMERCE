part of '../description_section.dart';

class _AttributesSection extends StatelessWidget {
  final Map<String, dynamic> attributes;

  const _AttributesSection({required this.attributes});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final visibleAttributes = attributes.entries
        .where((entry) {
          final key = entry.key.toLowerCase().trim();
          final value = entry.value?.toString().trim() ?? '';
          return value.isNotEmpty && key != 'color' && key != 'size';
        })
        .take(12)
        .toList();

    if (visibleAttributes.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.tune_rounded, size: 18, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              l10n.pick(ar: 'المواصفات والخصائص', en: 'Specifications & Attributes'),
              style: GoogleFonts.cairo(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: List.generate(visibleAttributes.length, (index) {
              final entry = visibleAttributes[index];
              final isEven = index % 2 == 0;

              return Container(
                color: isEven
                    ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
                    : Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Text(
                        entry.key,
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: Text(
                        entry.value.toString(),
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
