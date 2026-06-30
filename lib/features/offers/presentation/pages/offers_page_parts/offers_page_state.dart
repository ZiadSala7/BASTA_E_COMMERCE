part of '../offers_page.dart';

class _OffersPageState extends State<OffersPage> {
  int _selectedCategoryIndex = 0;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textDirection = l10n.isArabic ? TextDirection.rtl : TextDirection.ltr;
    final categories = [
      l10n.all,
      l10n.pick(ar: 'مستحضرات التجميل والعناية', en: 'Beauty and care'),
      l10n.fashion,
      l10n.pick(ar: 'إلكترونيات', en: 'Electronics'),
    ];
    final offers = _filteredOffers(_demoOffers(l10n), categories);

    return Directionality(
      textDirection: textDirection,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: CustomScrollView(
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: _OffersHeaderDelegate(
                topPadding: MediaQuery.paddingOf(context).top,
                title: l10n.pick(ar: 'خصم فوق الخصم', en: 'Discounts on deals'),
                hintText: l10n.pick(
                  ar: 'ابحث باسم الكوبون، المتجر',
                  en: 'Search coupon or store',
                ),
                onMenuTap: widget.onMenuPressed ?? () {},
                onNotificationTap: () => context.push(AppRoutes.notifications),
                onFilterTap: _showFilterSheet,
                onSearchChanged: (value) {
                  setState(() => _searchQuery = value.trim().toLowerCase());
                },
              ),
            ),
            SliverToBoxAdapter(
              child: _CategoryFilters(
                categories: categories,
                selectedIndex: _selectedCategoryIndex,
                onChanged: (index) {
                  setState(() => _selectedCategoryIndex = index);
                },
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
              sliver: SliverGrid.builder(
                itemCount: offers.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.68,
                ),
                itemBuilder: (context, index) {
                  return _OfferCouponCard(
                    offer: offers[index],
                    onTap: () => _showOfferDetails(offers[index]),
                    onCodeTap: () => _copyOfferCode(offers[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_OfferCoupon> _filteredOffers(
    List<_OfferCoupon> offers,
    List<String> categories,
  ) {
    return offers.where((offer) {
      final matchesCategory =
          _selectedCategoryIndex == 0 ||
          offer.category == categories[_selectedCategoryIndex];
      final query = _searchQuery;
      final matchesSearch =
          query.isEmpty ||
          offer.storeName.toLowerCase().contains(query) ||
          offer.code.toLowerCase().contains(query) ||
          offer.description.toLowerCase().contains(query);

      return matchesCategory && matchesSearch;
    }).toList();
  }

  void _showFilterSheet() {
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.pick(ar: 'تصفية العروض', en: 'Filter offers'),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    color: colorScheme.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                _FilterActionTile(
                  icon: Icons.local_offer_rounded,
                  label: l10n.pick(ar: 'أقوى الخصومات', en: 'Best discounts'),
                  onTap: () {
                    Navigator.of(context).pop();
                    setState(() => _selectedCategoryIndex = 0);
                  },
                ),
                _FilterActionTile(
                  icon: Icons.schedule_rounded,
                  label: l10n.pick(ar: 'الأحدث انتهاء', en: 'Ending soon'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showSnack(
                      l10n.pick(
                        ar: 'تم ترتيب العروض حسب الأقرب انتهاء',
                        en: 'Offers sorted by ending soon',
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showOfferDetails(_OfferCoupon offer) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _StoreAvatar(offer: offer),
                const SizedBox(height: 10),
                Text(
                  offer.storeName,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    color: colorScheme.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${offer.amount} - ${offer.description}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _copyOfferCode(offer);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: offer.buttonColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: const Size.fromHeight(46),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    offer.code,
                    style: GoogleFonts.cairo(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _copyOfferCode(_OfferCoupon offer) async {
    await Clipboard.setData(ClipboardData(text: offer.code));
    if (!mounted) return;

    final l10n = AppLocalizations.of(context)!;
    _showSnack(
      l10n.pick(ar: 'تم نسخ الكوبون ${offer.code}', en: 'Copied ${offer.code}'),
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message, style: GoogleFonts.cairo()),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}
