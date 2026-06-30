part of '../home_featured_stores_section.dart';

class _StoreImage extends StatelessWidget {
  final HomeFeaturedStore store;

  const _StoreImage({required this.store});

  @override
  Widget build(BuildContext context) {
    if (store.imageAsset != null && store.imageAsset!.isNotEmpty) {
      return Image.asset(
        store.imageAsset!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const _StorePlaceholder(),
      );
    }

    if (store.imageUrl.isEmpty) return const _StorePlaceholder();

    return Image.network(
      store.imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => const _StorePlaceholder(),
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const _StorePlaceholder();
      },
    );
  }
}
