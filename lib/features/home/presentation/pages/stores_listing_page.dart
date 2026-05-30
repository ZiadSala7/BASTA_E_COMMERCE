import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/extensions/app_localizations_x.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_router.dart';
import '../../../../core/widgets/common/custom_app_bar.dart';
import '../../../../core/widgets/status/empty_state.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/home_store_entity.dart';
import '../../domain/usecases/get_home_stores_usecase.dart';
import '../../../products/presentation/pages/products_listing_page.dart';

class StoresListingPage extends StatefulWidget {
  const StoresListingPage({super.key});

  @override
  State<StoresListingPage> createState() => _StoresListingPageState();
}

class _StoresListingPageState extends State<StoresListingPage> {
  static const int _pageLimit = 10;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  late final GetHomeStoresUseCase _getStores;

  final List<HomeStoreEntity> _stores = [];
  bool _isLoadingInitial = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _errorMessage;
  int _page = 1;

  @override
  void initState() {
    super.initState();
    _getStores = sl<GetHomeStoresUseCase>();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
    _loadFirstPage();
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  Future<void> _loadFirstPage() async {
    setState(() {
      _page = 1;
      _stores.clear();
      _hasMore = true;
      _errorMessage = null;
      _isLoadingInitial = true;
    });

    try {
      final storesPage = await _getStores(page: _page, limit: _pageLimit);
      if (!mounted) return;

      setState(() {
        _stores.addAll(storesPage.stores);
        _hasMore = storesPage.hasMore;
        _isLoadingInitial = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = _cleanError(error);
        _isLoadingInitial = false;
      });
    }
  }

  Future<void> _loadNextPage() async {
    if (_isLoadingInitial || _isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
      _errorMessage = null;
    });

    try {
      final nextPage = _page + 1;
      final storesPage = await _getStores(page: nextPage, limit: _pageLimit);
      if (!mounted) return;

      setState(() {
        _page = nextPage;
        _stores.addAll(storesPage.stores);
        _hasMore = storesPage.hasMore;
        _isLoadingMore = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = _cleanError(error);
        _isLoadingMore = false;
      });
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    if (_scrollController.position.extentAfter < 320) {
      _loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Column(
        children: [
          CustomAppBar(
            title: l10n.featuredStoresPageTitle,
            leading: IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
          _StoreSearchField(controller: _searchController),
          Expanded(child: _buildStoresGrid()),
        ],
      ),
    );
  }

  Widget _buildStoresGrid() {
    final l10n = AppLocalizations.of(context)!;
    final visibleStores = _filteredStores();

    if (_isLoadingInitial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_stores.isEmpty && _errorMessage != null) {
      return EmptyState(
        icon: Icons.wifi_off_rounded,
        title: l10n.couldNotLoadStores,
        message: _errorMessage,
        actionLabel: l10n.tryAgain,
        onActionTap: _loadFirstPage,
      );
    }

    if (_stores.isEmpty) {
      return EmptyState(
        icon: Icons.storefront_outlined,
        title: l10n.noStoresFound,
      );
    }

    if (visibleStores.isEmpty) {
      return EmptyState(
        icon: Icons.search_off_rounded,
        title: l10n.pick(ar: 'لا توجد نتائج', en: 'No matching stores'),
        message: l10n.pick(
          ar: 'جرّب البحث باسم متجر آخر.',
          en: 'Try searching for another store name.',
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFirstPage,
      child: GridView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.82,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: visibleStores.length + (_isLoadingMore ? 2 : 0),
        itemBuilder: (context, index) {
          if (index >= visibleStores.length) {
            return const Center(child: CircularProgressIndicator());
          }

          final store = visibleStores[index];
          return _StoreListingCard(
            store: store,
            onTap: () => context.push(
              AppRoutes.products,
              extra: ProductsListingArgs(
                storeSlug: store.slug,
                title: store.name,
              ),
            ),
          );
        },
      ),
    );
  }

  List<HomeStoreEntity> _filteredStores() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return List<HomeStoreEntity>.unmodifiable(_stores);

    return _stores
        .where((store) => store.name.toLowerCase().contains(query))
        .toList(growable: false);
  }

  void _onSearchChanged() {
    if (mounted) setState(() {});
  }

  String _cleanError(Object error) {
    return error.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
  }
}

class _StoreListingCard extends StatelessWidget {
  final HomeStoreEntity store;
  final VoidCallback onTap;

  const _StoreListingCard({required this.store, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _StoreIcon(),
                const SizedBox(height: 12),
                Text(
                  store.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                    color: colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: Text(
                    store.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 1.35,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.shopping_bag_outlined,
                      color: AppColors.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      l10n.viewProducts,
                      style: GoogleFonts.cairo(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StoreSearchField extends StatelessWidget {
  final TextEditingController controller;

  const _StoreSearchField({required this.controller});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: TextField(
        controller: controller,
        textInputAction: TextInputAction.search,
        style: GoogleFonts.cairo(
          color: colorScheme.onSurface,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: l10n.pick(
            ar: 'ابحث عن متجر بالاسم',
            en: 'Search stores by name',
          ),
          hintStyle: GoogleFonts.cairo(
            color: colorScheme.onSurfaceVariant,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, child) {
              if (value.text.isEmpty) return const SizedBox.shrink();

              return IconButton(
                tooltip: l10n.pick(ar: 'مسح البحث', en: 'Clear search'),
                onPressed: controller.clear,
                icon: const Icon(Icons.close_rounded),
              );
            },
          ),
          filled: true,
          fillColor: colorScheme.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.outlineVariant),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.outlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
          ),
        ),
      ),
    );
  }
}

class _StoreIcon extends StatelessWidget {
  const _StoreIcon();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.storefront_outlined,
        color: AppColors.primary,
        size: 26,
      ),
    );
  }
}
