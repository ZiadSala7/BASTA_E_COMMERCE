part of '../home_ad_carousel.dart';

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
