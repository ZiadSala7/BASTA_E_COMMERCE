// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import '../../../../core/utils/app_colors.dart';
import '../models/product_detail_args.dart';
import 'detail_product_image.dart';

class ProductHeader extends StatefulWidget {
  final ProductDetailArgs product;
  final bool isFavorite;
  final bool isFavoriteUpdating;
  final VoidCallback? onFavoriteTap;

  const ProductHeader({
    super.key,
    required this.product,
    this.isFavorite = false,
    this.isFavoriteUpdating = false,
    this.onFavoriteTap,
  });

  @override
  State<ProductHeader> createState() => _ProductHeaderState();
}

class _ProductHeaderState extends State<ProductHeader> {
  final PageController _pageController = PageController();
  int _selectedImage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.product.galleryImages;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 380,
      color: const Color(0xFFF7F8FA),
      child: Stack(
        children: [
          Positioned.fill(
            child: PageView.builder(
              controller: _pageController,
              itemCount: images.isEmpty ? 1 : images.length,
              onPageChanged: (index) => setState(() => _selectedImage = index),
              itemBuilder: (context, index) {
                final image = images.isEmpty ? null : images[index];

                return Padding(
                  padding: const EdgeInsets.fromLTRB(18, 72, 18, 58),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(17),
                      child: DetailProductImage(imageUrl: image),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  _HeaderIconButton(
                    icon: Icons.arrow_back_rounded,
                    onTap: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  _HeaderIconButton(icon: Icons.share_outlined, onTap: () {}),
                  const SizedBox(width: 8),
                  _HeaderIconButton(
                    icon: widget.isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: widget.isFavorite
                        ? AppColors.badgeRed
                        : const Color(0xFF111827),
                    isLoading: widget.isFavoriteUpdating,
                    onTap: widget.onFavoriteTap ?? () {},
                  ),
                ],
              ),
            ),
          ),
          if (widget.product.discountBadge?.isNotEmpty == true)
            Positioned(
              left: 24,
              bottom: 70,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.badgeRed,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.product.discountBadge!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          if (images.length > 1)
            Positioned(
              left: 0,
              right: 0,
              bottom: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  images.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: _selectedImage == index ? 20 : 7,
                    height: 7,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: _selectedImage == index
                          ? AppColors.primary
                          : colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final bool isLoading;
  final VoidCallback onTap;

  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
    this.color = const Color(0xFF111827),
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 0,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 42,
          height: 42,
          child: isLoading
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(icon, size: 21, color: color),
        ),
      ),
    );
  }
}
