part of '../home_page.dart';

class _CategoriesLoadingSection extends StatelessWidget {
  const _CategoriesLoadingSection();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 132,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}
