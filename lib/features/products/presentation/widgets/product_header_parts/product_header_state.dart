part of '../product_header.dart';

class _ProductHeaderState extends State<ProductHeader> {
  late final PageController _pageController;
  int _selectedImage = 0;

  @override
  void initState() {
    super.initState();
    _selectedImage = widget.selectedImageIndex;
    _pageController = PageController(initialPage: _selectedImage);
  }

  @override
  void didUpdateWidget(ProductHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedImageIndex != oldWidget.selectedImageIndex &&
        widget.selectedImageIndex != _selectedImage) {
      _selectedImage = widget.selectedImageIndex;
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _selectedImage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.product.galleryImages;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      color: isDark ? colorScheme.surface : const Color(0xFFF6F8FA),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 370,
            child: Stack(
              children: [
                Positioned.fill(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: images.isEmpty ? 1 : images.length,
                    onPageChanged: (index) {
                      setState(() => _selectedImage = index);
                      widget.onImageSelected?.call(index);
                    },
                    itemBuilder: (context, index) {
                      final image = images.isEmpty ? null : images[index];

                      return GestureDetector(
                        onTap: () => _openFullScreenGallery(images, index),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 68, 16, 16),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: isDark ? colorScheme.surfaceContainerHighest : Colors.white,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: colorScheme.outlineVariant.withValues(alpha: 0.6),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(21),
                              child: Hero(
                                tag: 'product_image_${widget.product.id}_$index',
                                child: DetailProductImage(
                                  imageUrl: image,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Top Floating Action Bar
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                    child: Row(
                      children: [
                        _HeaderIconButton(
                          icon: Icons.arrow_back_rounded,
                          onTap: () => Navigator.pop(context),
                        ),
                        const Spacer(),
                        _HeaderIconButton(
                          icon: Icons.share_outlined,
                          onTap: _shareProduct,
                        ),
                        const SizedBox(width: 8),
                        _HeaderIconButton(
                          icon: widget.isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: widget.isFavorite
                              ? AppColors.badgeRed
                              : (isDark ? Colors.white : const Color(0xFF111827)),
                          isLoading: widget.isFavoriteUpdating,
                          onTap: widget.onFavoriteTap ?? () {},
                        ),
                      ],
                    ),
                  ),
                ),

                // Sale / Discount Badge
                if (widget.product.discountBadge?.isNotEmpty == true)
                  PositionedDirectional(
                    start: 26,
                    bottom: 26,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE53935), Color(0xFFD32F2F)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE53935).withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Text(
                        widget.product.discountBadge!,
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ),

                // Page Indicator Dots
                if (images.length > 1)
                  PositionedDirectional(
                    end: 26,
                    bottom: 26,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_selectedImage + 1} / ${images.length}',
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Interactive Thumbnail Strip
          if (images.length > 1) ...[
            Container(
              height: 58,
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: images.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final isSelected = _selectedImage == index;

                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedImage = index);
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                      );
                      widget.onImageSelected?.call(index);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: isDark ? colorScheme.surfaceContainerHighest : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : colorScheme.outlineVariant.withValues(alpha: 0.7),
                          width: isSelected ? 2.2 : 1,
                        ),
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: DetailProductImage(
                          imageUrl: images[index],
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _shareProduct() {
    final title = widget.product.title;
    final price = widget.product.price;
    Share.share(
      '$title\nPrice: $price\nCheck out this product on Pasta e-Commerce!',
      subject: title,
    );
  }

  void _openFullScreenGallery(List<String> images, int initialIndex) {
    if (images.isEmpty) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: PageView.builder(
            itemCount: images.length,
            controller: PageController(initialPage: initialIndex),
            itemBuilder: (context, index) {
              return Center(
                child: InteractiveViewer(
                  panEnabled: true,
                  minScale: 0.8,
                  maxScale: 3.5,
                  child: DetailProductImage(
                    imageUrl: images[index],
                    fit: BoxFit.contain,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
