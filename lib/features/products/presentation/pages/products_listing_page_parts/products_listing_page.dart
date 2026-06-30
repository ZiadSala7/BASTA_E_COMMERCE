part of '../products_listing_page.dart';

class ProductsListingPage extends StatefulWidget {
  final ProductsListingArgs? args;
  final String? category;
  final String? storeId;

  const ProductsListingPage({
    super.key,
    this.args,
    this.category,
    this.storeId,
  });

  @override
  State<ProductsListingPage> createState() => _ProductsListingPageState();
}
