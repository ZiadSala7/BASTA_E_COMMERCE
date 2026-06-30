part of '../related_products_section.dart';

class RelatedProductsSection extends StatefulWidget {
  final ProductDetailArgs currentProduct;

  const RelatedProductsSection({super.key, required this.currentProduct});

  @override
  State<RelatedProductsSection> createState() => _RelatedProductsSectionState();
}
