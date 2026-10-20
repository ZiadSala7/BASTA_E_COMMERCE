part of '../home_featured_stores_section.dart';

class _StorePlaceholder extends StatelessWidget {
  const _StorePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        Icons.storefront_outlined,
        color: AppColors.primaryFor(context),
        size: 28,
      ),
    );
  }
}
