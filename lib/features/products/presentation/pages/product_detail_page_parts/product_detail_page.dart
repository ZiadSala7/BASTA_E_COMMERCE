part of '../product_detail_page.dart';

class ProductDetailPage extends StatefulWidget {
  final String productId;
  final ProductDetailArgs? product;
  final bool isLoading;
  final String? error;

  const ProductDetailPage({
    super.key,
    required this.productId,
    this.product,
    this.isLoading = false,
    this.error,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}
