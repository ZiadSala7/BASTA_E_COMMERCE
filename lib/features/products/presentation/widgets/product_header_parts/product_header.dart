part of '../product_header.dart';

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
