part of '../home_page.dart';

class _ProductsLoadingSection extends StatelessWidget {
  const _ProductsLoadingSection();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 274,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}
