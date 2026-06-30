part of '../home_search_results_section.dart';

class _SearchHeader extends StatelessWidget {
  final String query;

  const _SearchHeader({required this.query});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withOpacity(0.12)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, color: AppColors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l10n.pick(
                  ar: 'نتائج البحث عن "$query"',
                  en: 'Search results for "$query"',
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.cairo(
                  color: colorScheme.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
