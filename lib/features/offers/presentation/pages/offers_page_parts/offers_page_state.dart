part of '../offers_page.dart';

class _OffersPageState extends State<OffersPage> {
  late int _mainTabIndex; // 0: My Coupons & Rewards, 1: Store Deals
  int _userCouponFilterIndex = 0; // 0: All, 1: Active, 2: Inactive
  int _selectedCategoryIndex = 0;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _mainTabIndex = widget.initialTabIndex;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textDirection = l10n.isArabic ? TextDirection.rtl : TextDirection.ltr;

    final categories = [
      l10n.all,
      l10n.pick(ar: 'مستحضرات التجميل والعناية', en: 'Beauty and care'),
      l10n.fashion,
      l10n.pick(ar: 'إلكترونيات', en: 'Electronics'),
    ];
    final offers = _filteredOffers(_demoOffers(l10n), categories);

    return BlocProvider(
      create: (_) => sl<CouponsCubit>()..getMyCoupons(),
      child: Directionality(
        textDirection: textDirection,
        child: Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: Builder(
            builder: (blocContext) {
              return RefreshIndicator(
                onRefresh: () async {
                  if (_mainTabIndex == 0) {
                    await blocContext.read<CouponsCubit>().getMyCoupons(showLoading: false);
                  }
                },
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _OffersHeaderDelegate(
                        topPadding: MediaQuery.paddingOf(context).top,
                        title: _mainTabIndex == 0
                            ? l10n.pick(ar: 'مكافآتي وكوبوناتي', en: 'My Rewards & Coupons')
                            : l10n.pick(ar: 'خصم فوق الخصم', en: 'Discounts on deals'),
                        hintText: l10n.pick(
                          ar: 'ابحث باسم الكوبون، المتجر',
                          en: 'Search coupon or store',
                        ),
                        onMenuTap: widget.onMenuPressed ?? () {},
                        onNotificationTap: () =>
                            context.push(AppRoutes.notifications),
                        onFilterTap: _showFilterSheet,
                        onSearchChanged: (value) {
                          setState(() => _searchQuery = value.trim().toLowerCase());
                        },
                      ),
                    ),

                    // Main Tab Switcher: [My Coupons & Rewards] | [Store Deals]
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest.withOpacity(0.55),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: colorScheme.outlineVariant.withOpacity(0.6),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _OffersTabSegment(
                                  title: l10n.pick(
                                    ar: 'مكافآتي وكوبوناتي',
                                    en: 'My Rewards & Coupons',
                                  ),
                                  icon: Icons.card_giftcard_rounded,
                                  isSelected: _mainTabIndex == 0,
                                  onTap: () => setState(() => _mainTabIndex = 0),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: _OffersTabSegment(
                                  title: l10n.pick(
                                    ar: 'عروض المتاجر',
                                    en: 'Store Deals',
                                  ),
                                  icon: Icons.storefront_rounded,
                                  isSelected: _mainTabIndex == 1,
                                  onTap: () => setState(() => _mainTabIndex = 1),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    if (_mainTabIndex == 0) ...[
                      // TAB 0: My Rewards & Coupons (Backend dynamic coupons + referral reward)
                      _buildMyCouponsSliver(blocContext),
                    ] else ...[
                      // TAB 1: Store Deals & Offers
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
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
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

                    const SliverToBoxAdapter(child: SizedBox(height: 32)),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMyCouponsSliver(BuildContext blocContext) {
    final l10n = AppLocalizations.of(blocContext)!;
    final colorScheme = Theme.of(blocContext).colorScheme;

    return BlocConsumer<CouponsCubit, CouponsState>(
      listener: (context, state) {
        if (state is CouponsError) {
          _showSnack(state.message);
        }
      },
      builder: (context, state) {
        if (state is CouponsLoading) {
          return const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is CouponsError && state is! CouponsLoaded) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 50,
                      color: AppColors.badgeRed,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton.icon(
                      onPressed: () => context.read<CouponsCubit>().getMyCoupons(),
                      icon: const Icon(Icons.refresh_rounded),
                      label: Text(l10n.tryAgain),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (state is CouponsLoaded) {
          final allCoupons = state.coupons;
          final activeCoupons = state.activeCoupons;
          final inactiveCoupons = state.inactiveCoupons;

          final displayedCoupons = switch (_userCouponFilterIndex) {
            1 => activeCoupons,
            2 => inactiveCoupons,
            _ => allCoupons,
          };

          return SliverMainAxisGroup(
            slivers: [
              // Referral Earn Banner
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withValues(alpha: 0.85),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.22),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.card_giftcard_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.pick(
                                  ar: 'ادعُ أصدقاءك واكسب 5 د.أ! 🎉',
                                  en: 'Invite friends & earn JOD 5! 🎉',
                                ),
                                style: GoogleFonts.cairo(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                l10n.pick(
                                  ar: 'قسيمة ترحيبية لصديقك وقسيمة لك بعد أول طلب!',
                                  en: 'Welcome coupon for your friend & coupon for you on 1st order!',
                                ),
                                style: GoogleFonts.cairo(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => context.push(AppRoutes.inviteFriends),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primary,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            l10n.pick(ar: 'دعوة', en: 'Invite'),
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              if (allCoupons.isNotEmpty) ...[
                // Sub-filter chips: All / Active / Inactive
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        _buildFilterChip(
                          blocContext,
                          index: 0,
                          label: l10n.pick(ar: 'الكل', en: 'All'),
                          count: allCoupons.length,
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          blocContext,
                          index: 1,
                          label: l10n.pick(ar: 'نشطة', en: 'Active'),
                          count: activeCoupons.length,
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          blocContext,
                          index: 2,
                          label: l10n.pick(ar: 'غير نشطة', en: 'Inactive'),
                          count: inactiveCoupons.length,
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              if (allCoupons.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyCouponsView(
                    onRefresh: () => context.read<CouponsCubit>().getMyCoupons(),
                  ),
                )
              else if (displayedCoupons.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 48,
                            color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l10n.pick(
                              ar: 'لا توجد كوبونات في هذا القسم',
                              en: 'No coupons in this section',
                            ),
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final coupon = displayedCoupons[index];
                      return CouponCard(coupon: coupon);
                    },
                    childCount: displayedCoupons.length,
                  ),
                ),
            ],
          );
        }

        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required int index,
    required String label,
    required int count,
  }) {
    final isSelected = _userCouponFilterIndex == index;
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _userCouponFilterIndex = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary
                : colorScheme.surfaceContainerHighest.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : colorScheme.outlineVariant.withOpacity(0.5),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? Colors.white : colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.25)
                      : colorScheme.onSurface.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$count',
                  style: GoogleFonts.cairo(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: isSelected
                        ? Colors.white
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
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

class _OffersTabSegment extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _OffersTabSegment({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.26),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 17,
                color: isSelected ? Colors.white : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                    color: isSelected ? Colors.white : colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
