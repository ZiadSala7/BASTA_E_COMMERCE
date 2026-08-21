part of '../products_listing_page.dart';

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late double _minPrice;
  late double _maxPrice;
  late String _sortBy;
  late bool _showOnlySales;

  @override
  void initState() {
    super.initState();
    _minPrice = widget.currentMinPrice;
    _maxPrice = widget.currentMaxPrice;
    _sortBy = widget.currentSortBy;
    _showOnlySales = widget.showOnlySales;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(20),
      height: MediaQuery.of(context).size.height * 0.86,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.pick(ar: 'تصفية المنتجات', en: 'Filter Products'),
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(
                    title: l10n.pick(ar: 'نطاق السعر', en: 'Price Range'),
                    subtitle: l10n.pick(
                      ar: 'اختر ميزانية التسوق المناسبة لهذا التصفح.',
                      en: 'Choose the shopping budget that fits this browse.',
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 12),
                  RangeSlider(
                    values: RangeValues(_minPrice, _maxPrice),
                    min: 0,
                    max: 10000,
                    divisions: 20,
                    labels: RangeLabels(
                      l10n.formatPrice(_minPrice.toInt(), 0),
                      l10n.formatPrice(_maxPrice.toInt(), 0),
                    ),
                    onChanged: (values) {
                      setState(() {
                        _minPrice = values.start;
                        _maxPrice = values.end;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  SectionHeader(
                    title: l10n.pick(ar: 'ترتيب حسب', en: 'Sort By'),
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 12),
                  _buildSortOptions(l10n),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        l10n.pick(
                          ar: 'عرض منتجات العروض فقط',
                          en: 'Show Sale Items Only',
                        ),
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Switch(
                        value: _showOnlySales,
                        onChanged: (value) =>
                            setState(() => _showOnlySales = value),
                        activeThumbColor: AppColors.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => widget.onApplyFilters(
                _minPrice,
                _maxPrice,
                _sortBy,
                _showOnlySales,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                l10n.pick(ar: 'تطبيق الفلاتر', en: 'Apply Filters'),
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortOptions(AppLocalizations l10n) {
    final options = [
      {
        'value': 'newest',
        'label': l10n.pick(ar: 'الأحدث أولاً', en: 'Newest First'),
        'icon': Icons.fiber_new,
      },
      {
        'value': 'price_low',
        'label': l10n.pick(
          ar: 'السعر: من الأقل للأعلى',
          en: 'Price: Low to High',
        ),
        'icon': Icons.arrow_upward,
      },
      {
        'value': 'price_high',
        'label': l10n.pick(
          ar: 'السعر: من الأعلى للأقل',
          en: 'Price: High to Low',
        ),
        'icon': Icons.arrow_downward,
      },
      {
        'value': 'sale',
        'label': l10n.pick(ar: 'أفضل العروض', en: 'Best Sale'),
        'icon': Icons.local_offer,
      },
    ];

    return Column(
      children: options.map((option) {
        final isSelected = _sortBy == option['value'];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: SelectableTile(
            selected: isSelected,
            onTap: () => setState(() => _sortBy = option['value'] as String),
            leading: Icon(
              option['icon'] as IconData,
              color: isSelected ? AppColors.primary : const Color(0xFF6B7280),
            ),
            title: option['label'] as String,
          ),
        );
      }).toList(),
    );
  }
}
