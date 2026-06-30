part of '../stores_listing_page.dart';

class _StoreIcon extends StatelessWidget {
  const _StoreIcon();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.storefront_outlined,
        color: AppColors.primary,
        size: 26,
      ),
    );
  }
}
