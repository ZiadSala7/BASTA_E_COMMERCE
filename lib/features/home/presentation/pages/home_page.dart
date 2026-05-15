import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/app_router.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/extensions/app_localizations_x.dart';
import '../../../../l10n/app_localizations.dart';
import '../widgets/home_ad_carousel.dart';
import '../widgets/home_featured_products_section.dart';
import '../widgets/home_featured_stores_section.dart';
import '../widgets/home_page_categories_strip.dart';

class HomePage extends StatefulWidget {
  final VoidCallback? onMenuPressed;

  const HomePage({super.key, this.onMenuPressed});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  List<HomeAdBanner> _demoAds(AppLocalizations l10n) => [
    HomeAdBanner(
      id: '1',
      title: l10n.adTitle1,
      buttonText: l10n.shopNow,
      imageUrl:
          'https://images.unsplash.com/photo-1592945403244-b3fbafd7f539?auto=format&fit=crop&w=1100&q=85',
    ),
    HomeAdBanner(
      id: '2',
      title: l10n.adTitle2,
      buttonText: l10n.shopNow,
      imageUrl:
          'https://images.unsplash.com/photo-1523293182086-7651a899d37f?auto=format&fit=crop&w=1100&q=85',
    ),
    HomeAdBanner(
      id: '3',
      title: l10n.adTitle3,
      buttonText: l10n.shopNow,
      imageUrl:
          'https://images.unsplash.com/photo-1608571423902-eed4a5ad8108?auto=format&fit=crop&w=1100&q=85',
    ),
  ];

  List<HomeFeaturedProduct> _demoFeaturedProducts(AppLocalizations l10n) => [
    HomeFeaturedProduct(
      id: '1',
      title: l10n.featuredProductThailand,
      price: l10n.jdPrice('49'),
      oldPrice: l10n.jdPrice('92'),
      reviewCount: 10,
      imageUrl:
          'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=420&q=85',
    ),
    HomeFeaturedProduct(
      id: '2',
      title: l10n.featuredProductBakhoor,
      price: l10n.jdPrice('49'),
      oldPrice: l10n.jdPrice('92'),
      discountLabel: '%14',
      reviewCount: 10,
      imageUrl:
          'https://images.unsplash.com/photo-1608571423902-eed4a5ad8108?auto=format&fit=crop&w=420&q=85',
    ),
    HomeFeaturedProduct(
      id: '3',
      title: l10n.featuredProductGifts,
      price: l10n.jdPrice('39'),
      reviewCount: 8,
      imageUrl:
          'https://images.unsplash.com/photo-1513885535751-8b9238bd345a?auto=format&fit=crop&w=420&q=85',
    ),
  ];

  List<HomeFeaturedProduct> _demoSchoolDesigns(AppLocalizations l10n) => [
    HomeFeaturedProduct(
      id: 'school-1',
      title: l10n.schoolDesignAwarenessFile,
      price: l10n.jdPrice('37'),
      reviewCount: 10,
      imageUrl:
          'https://images.unsplash.com/photo-1586281380117-5a60ae2050cc?auto=format&fit=crop&w=420&q=85',
    ),
    HomeFeaturedProduct(
      id: 'school-2',
      title: l10n.schoolDesignCertificateLink,
      price: l10n.jdPrice('20'),
      reviewCount: 10,
      imageUrl:
          'https://images.unsplash.com/photo-1554224155-6726b3ff858f?auto=format&fit=crop&w=420&q=85',
    ),
    HomeFeaturedProduct(
      id: 'school-3',
      title: l10n.schoolDesignStudentFile,
      price: l10n.jdPrice('20'),
      reviewCount: 8,
      imageUrl:
          'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=420&q=85',
    ),
  ];

  List<HomeFeaturedStore> _demoFeaturedStores(AppLocalizations l10n) => [
    HomeFeaturedStore(
      id: 'store-1',
      name: l10n.storeSindibad,
      imageUrl:
          'https://images.unsplash.com/photo-1592945403244-b3fbafd7f539?auto=format&fit=crop&w=220&q=85',
    ),
    HomeFeaturedStore(
      id: 'store-2',
      name: l10n.storeShamiBikes,
      imageUrl:
          'https://images.unsplash.com/photo-1485965120184-e220f721d03e?auto=format&fit=crop&w=220&q=85',
    ),
    HomeFeaturedStore(
      id: 'store-3',
      name: l10n.storeDukhanOud,
      imageUrl:
          'https://images.unsplash.com/photo-1608571423902-eed4a5ad8108?auto=format&fit=crop&w=220&q=85',
    ),
    HomeFeaturedStore(
      id: 'store-4',
      name: l10n.storeSmartLibrary,
      imageUrl:
          'https://images.unsplash.com/photo-1586281380349-632531db7ed4?auto=format&fit=crop&w=220&q=85',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      key: _scaffoldKey,
      drawer: widget.onMenuPressed == null ? const AppDrawer() : null,
      appBar: CustomAppBar(
        onMenuPressed:
            widget.onMenuPressed ??
            () => _scaffoldKey.currentState?.openDrawer(),
        onNotificationPressed: () => context.push(AppRoutes.notifications),
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 12, bottom: 24),
        children: [
          HomeAdCarousel(items: _demoAds(l10n)),
          const SizedBox(height: 20),
          const HomePageCategoriesStrip(),
          const SizedBox(height: 18),
          HomeFeaturedProductsSection(items: _demoFeaturedProducts(l10n)),
          const SizedBox(height: 22),
          HomeFeaturedProductsSection(
            title: l10n.discoverSchoolDesigns,
            items: _demoSchoolDesigns(l10n),
            showRisingBadge: false,
          ),
          const SizedBox(height: 22),
          HomeFeaturedStoresSection(stores: _demoFeaturedStores(l10n)),
        ],
      ),
    );
  }
}
