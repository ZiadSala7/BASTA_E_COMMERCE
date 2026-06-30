part of '../home_ad_carousel.dart';

class _BannerFallback extends StatelessWidget {
  const _BannerFallback();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF07143D), Color(0xFF102E70), Color(0xFF07143D)],
        ),
      ),
    );
  }
}
