part of '../home_ad_carousel.dart';

class HomeAdCarousel extends StatefulWidget {
  final List<HomeAdBanner> items;
  final ValueChanged<HomeAdBanner>? onBannerTap;
  final Duration autoPlayInterval;

  const HomeAdCarousel({
    super.key,
    required this.items,
    this.onBannerTap,
    this.autoPlayInterval = const Duration(seconds: 4),
  });

  @override
  State<HomeAdCarousel> createState() => _HomeAdCarouselState();
}
