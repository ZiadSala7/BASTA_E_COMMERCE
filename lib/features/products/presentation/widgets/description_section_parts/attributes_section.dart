part of '../description_section.dart';

class _AttributesSection extends StatelessWidget {
  final Map<String, dynamic> attributes;

  const _AttributesSection({required this.attributes});

  @override
  Widget build(BuildContext context) {
    final visibleAttributes = attributes.entries
        .where((entry) {
          final key = entry.key.toLowerCase().trim();
          final value = entry.value?.toString().trim() ?? '';
          return value.isNotEmpty && key != 'color' && key != 'size';
        })
        .take(8)
        .toList();

    if (visibleAttributes.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Specifications',
          style: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        ...visibleAttributes.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 120,
                  child: Text(
                    entry.key,
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    entry.value.toString(),
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
