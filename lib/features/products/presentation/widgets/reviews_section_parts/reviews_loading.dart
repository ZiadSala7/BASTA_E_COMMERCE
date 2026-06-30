part of '../reviews_section.dart';

class _ReviewsLoading extends StatelessWidget {
  const _ReviewsLoading();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 92,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.38),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2.4),
      ),
    );
  }
}
