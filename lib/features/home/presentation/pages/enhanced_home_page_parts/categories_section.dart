part of '../enhanced_home_page.dart';

class _CategoriesSection extends StatelessWidget {
  final List<Map<String, dynamic>> categories;

  const _CategoriesSection({required this.categories});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Categories',
          actionLabel: 'See All',
          onActionTap: () => context.push(AppRoutes.products),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final category = categories[index];
              return _CategoryItem(
                icon: category['icon'],
                label: category['label'],
                color: category['color'],
                onTap: () {
                  context.push(AppRoutes.products, extra: category['label']);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
