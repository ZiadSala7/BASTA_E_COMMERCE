part of '../home_page.dart';

class _StoresLoadingSection extends StatelessWidget {
  const _StoresLoadingSection();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 164,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}
