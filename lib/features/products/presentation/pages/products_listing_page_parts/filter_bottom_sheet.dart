part of '../products_listing_page.dart';

class _FilterBottomSheet extends StatefulWidget {
  final double currentMinPrice;
  final double currentMaxPrice;
  final String currentSortBy;
  final bool showOnlySales;
  final Function(double, double, String, bool) onApplyFilters;

  const _FilterBottomSheet({
    required this.currentMinPrice,
    required this.currentMaxPrice,
    required this.currentSortBy,
    required this.showOnlySales,
    required this.onApplyFilters,
  });

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}
