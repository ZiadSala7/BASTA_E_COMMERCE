part of '../product_header.dart';

class ProductHeader extends StatefulWidget {
  final ProductDetailArgs product;
  final bool isFavorite;
  final bool isFavoriteUpdating;
  final VoidCallback? onFavoriteTap;
  final int selectedImageIndex;
  final ValueChanged<int>? onImageSelected;

  const ProductHeader({
    super.key,
    required this.product,
    this.isFavorite = false,
    this.isFavoriteUpdating = false,
    this.onFavoriteTap,
    this.selectedImageIndex = 0,
    this.onImageSelected,
  });

  @override
  State<ProductHeader> createState() => _ProductHeaderState();
}
