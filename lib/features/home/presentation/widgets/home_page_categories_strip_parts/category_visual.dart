part of '../home_page_categories_strip.dart';

class _CategoryVisual extends StatelessWidget {
  const _CategoryVisual({required this.data});

  final _CategoryData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: data.accent.withOpacity(0.11),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: data.accent.withOpacity(0.18)),
      ),
      child: Icon(data.icon, color: data.accent, size: 25),
    );
  }
}
