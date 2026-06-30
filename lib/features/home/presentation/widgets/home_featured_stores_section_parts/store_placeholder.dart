part of '../home_featured_stores_section.dart';

class _StorePlaceholder extends StatelessWidget {
  const _StorePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(
        Icons.storefront_outlined,
        color: AppColors.primary,
        size: 28,
      ),
    );
  }
}
