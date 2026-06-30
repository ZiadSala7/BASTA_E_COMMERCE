part of '../home_ad_carousel.dart';

class _BannerImage extends StatelessWidget {
  final HomeAdBanner banner;

  const _BannerImage({required this.banner});

  @override
  Widget build(BuildContext context) {
    if (banner.imageAsset != null && banner.imageAsset!.isNotEmpty) {
      return Image.asset(
        banner.imageAsset!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const _BannerFallback(),
      );
    }

    if (banner.imageUrl.isEmpty) {
      return const _BannerFallback();
    }

    return Image.network(
      banner.imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => const _BannerFallback(),
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const _BannerFallback();
      },
    );
  }
}
