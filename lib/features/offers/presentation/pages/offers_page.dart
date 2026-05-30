// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/extensions/app_localizations_x.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_router.dart';
import '../../../../l10n/app_localizations.dart';

class OffersPage extends StatefulWidget {
  final VoidCallback? onMenuPressed;

  const OffersPage({super.key, this.onMenuPressed});

  @override
  State<OffersPage> createState() => _OffersPageState();
}

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

class _OffersHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double topPadding;
  final String title;
  final String hintText;
  final VoidCallback onMenuTap;
  final VoidCallback onNotificationTap;
  final VoidCallback onFilterTap;
  final ValueChanged<String> onSearchChanged;

  const _OffersHeaderDelegate({
    required this.topPadding,
    required this.title,
    required this.hintText,
    required this.onMenuTap,
    required this.onNotificationTap,
    required this.onFilterTap,
    required this.onSearchChanged,
  });

  @override
  double get minExtent => topPadding + 150;

  @override
  double get maxExtent => topPadding + 150;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return _OffersHeader(
      topPadding: topPadding,
      title: title,
      hintText: hintText,
      onMenuTap: onMenuTap,
      onNotificationTap: onNotificationTap,
      onFilterTap: onFilterTap,
      onSearchChanged: onSearchChanged,
    );
  }

  @override
  bool shouldRebuild(covariant _OffersHeaderDelegate oldDelegate) {
    return topPadding != oldDelegate.topPadding ||
        title != oldDelegate.title ||
        hintText != oldDelegate.hintText;
  }
}

class _OffersHeader extends StatelessWidget {
  final double topPadding;
  final String title;
  final String hintText;
  final VoidCallback onMenuTap;
  final VoidCallback onNotificationTap;
  final VoidCallback onFilterTap;
  final ValueChanged<String> onSearchChanged;

  const _OffersHeader({
    required this.topPadding,
    required this.title,
    required this.hintText,
    required this.onMenuTap,
    required this.onNotificationTap,
    required this.onFilterTap,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.18),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
        child: Container(
          padding: EdgeInsets.only(
            top: topPadding + 14,
            left: 20,
            right: 20,
            bottom: 16,
          ),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF4747C2), Color(0xFF5B5BD6), Color(0xFF20B7A8)],
            ),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 48,
                child: Row(
                  textDirection: TextDirection.ltr,
                  children: [
                    _HeaderIconButton(
                      icon: Icons.menu_rounded,
                      onTap: onMenuTap,
                    ),
                    const SizedBox(width: 10),
                    _HeaderIconButton(
                      icon: Icons.notifications_none_rounded,
                      onTap: onNotificationTap,
                      showDot: true,
                    ),
                    const Spacer(),
                    Flexible(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.cairo(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              height: 1.05,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            AppLocalizations.of(context)!.offers,
                            style: GoogleFonts.cairo(
                              color: Colors.white.withOpacity(0.78),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                textDirection: TextDirection.ltr,
                children: [
                  Material(
                    color: Colors.white.withOpacity(0.96),
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      onTap: onFilterTap,
                      borderRadius: BorderRadius.circular(14),
                      child: const SizedBox(
                        width: 46,
                        height: 46,
                        child: Icon(
                          Icons.tune_rounded,
                          color: AppColors.primary,
                          size: 23,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: TextField(
                        onChanged: onSearchChanged,
                        textAlignVertical: TextAlignVertical.center,
                        decoration: InputDecoration(
                          hintText: hintText,
                          hintStyle: GoogleFonts.cairo(
                            color: colorScheme.onSurfaceVariant.withOpacity(
                              0.72,
                            ),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: AppColors.primary,
                            size: 21,
                          ),
                          filled: true,
                          fillColor: colorScheme.surface.withOpacity(0.96),
                          contentPadding: EdgeInsets.zero,
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.2),
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool showDot;

  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
    this.showDot = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.14),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 42,
          height: 42,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 22),
              if (showDot)
                PositionedDirectional(
                  top: 9,
                  end: 9,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.badgeRed,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.2),
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

class _CategoryFilters extends StatelessWidget {
  final List<String> categories;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _CategoryFilters({
    required this.categories,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      height: 62,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 2),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;

          return InkWell(
            onTap: () => onChanged(index),
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? AppColors.primary : theme.dividerColor,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isSelected ? AppColors.primary : Colors.black)
                        .withOpacity(isSelected ? 0.18 : 0.04),
                    blurRadius: isSelected ? 18 : 10,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: Text(
                categories[index],
                style: GoogleFonts.cairo(
                  color: isSelected
                      ? Colors.white
                      : colorScheme.onSurfaceVariant,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _OfferCouponCard extends StatelessWidget {
  final _OfferCoupon offer;
  final VoidCallback onTap;
  final VoidCallback onCodeTap;

  const _OfferCouponCard({
    required this.offer,
    required this.onTap,
    required this.onCodeTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              theme.brightness == Brightness.dark ? 0.20 : 0.065,
            ),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _OfferHeroBand(offer: offer),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _StoreAvatar(offer: offer),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            offer.storeName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.cairo(
                              color: colorScheme.onSurface,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              height: 1.05,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            offer.category,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.cairo(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  offer.amount,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                    color: AppColors.primary,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  offer.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      color: offer.buttonColor,
                      size: 12,
                    ),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        offer.expiry,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cairo(
                          color: offer.buttonColor,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          height: 1,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                InkWell(
                  onTap: onCodeTap,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 30,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [offer.buttonColor, offer.accent],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: offer.buttonColor.withOpacity(0.24),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.copy_rounded,
                          color: Colors.white,
                          size: 12,
                        ),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            offer.code,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.cairo(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              height: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StoreAvatar extends StatelessWidget {
  final _OfferCoupon offer;

  const _StoreAvatar({required this.offer});

  @override
  Widget build(BuildContext context) {
    const double avatarSize = 28;
    const double iconSize = 14;

    return Center(
      child: Container(
        width: avatarSize,
        height: avatarSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [offer.accent.withOpacity(0.24), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(offer.icon, color: offer.accent, size: iconSize),
      ),
    );
  }
}

class _OfferHeroBand extends StatelessWidget {
  final _OfferCoupon offer;

  const _OfferHeroBand({required this.offer});

  @override
  Widget build(BuildContext context) {

    return Container(
      height: 50,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: offer.imageColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -8,
            left: -6,
            child: Icon(
              offer.icon,
              color: Colors.white.withOpacity(0.16),
              size: 40,
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.20),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white.withOpacity(0.18)),
              ),
              child: Text(
                'HOT',
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: 7,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.92),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(offer.icon, color: offer.accent, size: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _FilterActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AppColors.primary),
      title: Text(
        label,
        style: GoogleFonts.cairo(
          color: colorScheme.onSurface,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: colorScheme.onSurfaceVariant,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}

class _OfferCoupon {
  final String storeName;
  final String category;
  final String amount;
  final String description;
  final String expiry;
  final String code;
  final Color accent;
  final Color buttonColor;
  final IconData icon;
  final List<Color> imageColors;

  const _OfferCoupon({
    required this.storeName,
    required this.category,
    required this.amount,
    required this.description,
    required this.expiry,
    required this.code,
    required this.accent,
    required this.buttonColor,
    required this.icon,
    required this.imageColors,
  });
}

List<_OfferCoupon> _demoOffers(AppLocalizations l10n) {
  final isArabic = l10n.isArabic;
  final dinar20 = isArabic ? '20 دينار' : '20 JOD';
  final dinar49 = isArabic ? '49 دينار' : '49 JOD';
  final discount20 = isArabic ? 'خصم كوبون' : 'Coupon discount';
  final freeShipping = isArabic ? 'شحن مجاني' : 'Free shipping';
  final expiresGreen = isArabic ? 'ينتهي في 8 أيام' : 'Ends in 8 days';
  final expiresGold = isArabic ? 'ينتهي في 24 أيام' : 'Ends in 24 days';
  final beauty = l10n.pick(
    ar: 'مستحضرات التجميل والعناية',
    en: 'Beauty and care',
  );
  final electronics = l10n.pick(ar: 'إلكترونيات', en: 'Electronics');

  return [
    _OfferCoupon(
      storeName: l10n.storeDukhanOud,
      category: l10n.fashion,
      amount: dinar20,
      description: discount20,
      expiry: expiresGreen,
      code: 'm3453',
      accent: const Color(0xFF6B6046),
      buttonColor: const Color(0xFF24D84E),
      icon: Icons.spa_rounded,
      imageColors: const [Color(0xFF082A52), Color(0xFF1B6BA6)],
    ),
    _OfferCoupon(
      storeName: l10n.storeSindibad,
      category: beauty,
      amount: dinar49,
      description: freeShipping,
      expiry: expiresGold,
      code: isArabic ? 'مفعل' : 'Active',
      accent: const Color(0xFFD98A2B),
      buttonColor: const Color(0xFFFFC85C),
      icon: Icons.storefront_rounded,
      imageColors: const [Color(0xFF101B48), Color(0xFF4976D8)],
    ),
    _OfferCoupon(
      storeName: l10n.storeSindibad,
      category: beauty,
      amount: dinar49,
      description: freeShipping,
      expiry: expiresGold,
      code: 'm6B',
      accent: const Color(0xFFD98A2B),
      buttonColor: const Color(0xFFFFC85C),
      icon: Icons.shopping_bag_rounded,
      imageColors: const [Color(0xFF1A2D62), Color(0xFF123E8A)],
    ),
    _OfferCoupon(
      storeName: l10n.storeDukhanOud,
      category: electronics,
      amount: dinar20,
      description: discount20,
      expiry: expiresGreen,
      code: 'np8567',
      accent: const Color(0xFF6B6046),
      buttonColor: const Color(0xFF24D84E),
      icon: Icons.card_giftcard_rounded,
      imageColors: const [Color(0xFF0B3D5E), Color(0xFF26A2C8)],
    ),
    _OfferCoupon(
      storeName: l10n.storeDukhanOud,
      category: l10n.fashion,
      amount: dinar20,
      description: discount20,
      expiry: expiresGreen,
      code: 'ouD20',
      accent: const Color(0xFF6B6046),
      buttonColor: const Color(0xFF24D84E),
      icon: Icons.local_mall_rounded,
      imageColors: const [Color(0xFF12304B), Color(0xFF59B7D4)],
    ),
    _OfferCoupon(
      storeName: l10n.storeSindibad,
      category: electronics,
      amount: dinar49,
      description: freeShipping,
      expiry: expiresGold,
      code: isArabic ? 'مفعل' : 'Active',
      accent: const Color(0xFFD98A2B),
      buttonColor: const Color(0xFFFFC85C),
      icon: Icons.workspace_premium_rounded,
      imageColors: const [Color(0xFF07143A), Color(0xFF385AD1)],
    ),
  ];
}
