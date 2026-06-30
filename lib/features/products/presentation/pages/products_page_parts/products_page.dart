part of '../products_page.dart';

class ProductsPage extends StatelessWidget {
  final String? category;
  final String? title;

  const ProductsPage({super.key, this.category, this.title});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: title ?? l10n.products,
        centerTitle: true,
        showSearch: false,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        ),
        actions: [
          _HeaderActionButton(
            icon: Icons.filter_list_rounded,
            onPressed: () {},
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.75,
        ),
        itemCount: 10,
        itemBuilder: (context, index) {
          return _ProductCard(index: index);
        },
      ),
    );
  }
}
