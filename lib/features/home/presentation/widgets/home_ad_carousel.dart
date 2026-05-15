// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/utils/app_colors.dart';

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

class _HomeAdCarouselState extends State<HomeAdCarousel> {
  final _pageController = PageController(viewportFraction: 0.86);
  int _currentIndex = 0;
  Timer? _autoPlayTimer;

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  @override
  void didUpdateWidget(covariant HomeAdCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items.length != widget.items.length ||
        oldWidget.autoPlayInterval != widget.autoPlayInterval) {
      _startAutoPlay();
    }
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    if (widget.items.length < 2) return;

    _autoPlayTimer = Timer.periodic(widget.autoPlayInterval, (_) {
      if (!mounted || !_pageController.hasClients) return;

      final nextIndex = (_currentIndex + 1) % widget.items.length;
      _pageController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 360),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final pageWidth = width * _pageController.viewportFraction;
        final cardHeight = (pageWidth / 2.2).clamp(148.0, 236.0).toDouble();

        return Column(
          children: [
            SizedBox(
              height: cardHeight,
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.items.length,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                },
                itemBuilder: (context, index) {
                  final banner = widget.items[index];

                  return AnimatedBuilder(
                    animation: _pageController,
                    builder: (context, child) {
                      var scale = 1.0;
                      if (_pageController.hasClients &&
                          _pageController.position.haveDimensions) {
                        final page = _pageController.page ?? _currentIndex;
                        scale = (1 - (page - index).abs() * 0.05)
                            .clamp(0.95, 1.0)
                            .toDouble();
                      }

                      return Transform.scale(scale: scale, child: child);
                    },
                    child: _AdBannerCard(
                      banner: banner,
                      onTap: widget.onBannerTap == null
                          ? null
                          : () => widget.onBannerTap!(banner),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),
            _AdCarouselIndicator(
              count: widget.items.length,
              activeIndex: _currentIndex,
            ),
          ],
        );
      },
    );
  }
}

class _AdBannerCard extends StatelessWidget {
  final HomeAdBanner banner;
  final VoidCallback? onTap;

  const _AdBannerCard({required this.banner, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Ink(
            decoration: BoxDecoration(
              color: const Color(0xFF101735),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 28,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxHeight < 180;

                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      _BannerImage(banner: banner),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Color(0x15000000),
                              Color(0x26000000),
                              Color(0x9C071038),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          compact ? 18 : 22,
                          compact ? 16 : 20,
                          compact ? 20 : 28,
                          compact ? 16 : 20,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              banner.title,
                              textAlign: TextAlign.right,
                              maxLines: compact ? 2 : 3,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.cairo(
                                color: Colors.white,
                                fontSize: compact ? 15 : 20,
                                fontWeight: FontWeight.w800,
                                height: 1.32,
                              ),
                            ),
                            const Spacer(),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: IntrinsicWidth(
                                child: Container(
                                  height: compact ? 34 : 46,
                                  constraints: BoxConstraints(
                                    minWidth: compact ? 92 : 124,
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: compact ? 18 : 26,
                                  ),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryDark,
                                    borderRadius: BorderRadius.circular(23),
                                  ),
                                  child: Text(
                                    banner.buttonText,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.cairo(
                                      color: Colors.white,
                                      fontSize: compact ? 12 : 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

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

class _AdCarouselIndicator extends StatelessWidget {
  final int count;
  final int activeIndex;

  const _AdCarouselIndicator({required this.count, required this.activeIndex});

  @override
  Widget build(BuildContext context) {
    if (count < 2) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var index = 0; index < count; index++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: index == activeIndex ? 46 : 10,
            height: 10,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: index == activeIndex
                  ? AppColors.primaryDark
                  : const Color(0xFFD5DCE3),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
      ],
    );
  }
}

class HomeAdBanner {
  final String id;
  final String title;
  final String buttonText;
  final String imageUrl;
  final String? imageAsset;
  final String? targetUrl;

  const HomeAdBanner({
    required this.id,
    required this.title,
    required this.buttonText,
    this.imageUrl = '',
    this.imageAsset,
    this.targetUrl,
  });

  factory HomeAdBanner.fromJson(Map<String, dynamic> json) {
    return HomeAdBanner(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? json['name'] ?? '').toString(),
      buttonText:
          (json['button_text'] ??
                  json['buttonText'] ??
                  '\u062a\u0633\u0648\u0642 \u0627\u0644\u0622\u0646')
              .toString(),
      imageUrl: (json['image_url'] ?? json['imageUrl'] ?? '').toString(),
      targetUrl:
          (json['target_url'] ??
                  json['targetUrl'] ??
                  json['redirect_url'] ??
                  json['redirectUrl'])
              ?.toString(),
    );
  }

  static List<HomeAdBanner> listFromJson(List<dynamic> json) {
    return json
        .whereType<Map>()
        .map((item) => HomeAdBanner.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }
}
