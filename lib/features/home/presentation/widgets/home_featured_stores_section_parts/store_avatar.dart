part of '../home_featured_stores_section.dart';

class _StoreAvatar extends StatelessWidget {
  final HomeFeaturedStore store;

  const _StoreAvatar({required this.store});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.45),
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: _StoreImage(store: store),
    );
  }
}
