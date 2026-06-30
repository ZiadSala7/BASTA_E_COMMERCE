part of '../stores_listing_page.dart';

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
