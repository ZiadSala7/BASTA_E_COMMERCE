// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/extensions/app_localizations_x.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

class HomeFeaturedStoresSection extends StatelessWidget {
  final List<HomeFeaturedStore> stores;
  final VoidCallback? onShowAllTap;
  final ValueChanged<HomeFeaturedStore>? onStoreTap;

  const HomeFeaturedStoresSection({
    super.key,
    required this.stores,
    this.onShowAllTap,
    this.onStoreTap,
  });

  @override
  Widget build(BuildContext context) {
    if (stores.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: .spaceBetween,
            textDirection: l10n.isArabic
                ? TextDirection.rtl
                : TextDirection.ltr,
            children: [
              Expanded(
                child: Text(
                  l10n.featuredStores,
                  style: GoogleFonts.cairo(
                    color: AppColors.textPrimary,
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
              ),
              TextButton(
                onPressed: onShowAllTap ?? () {},
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF1687F5),
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  minimumSize: const Size(0, 36),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  l10n.showAll,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 116,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            itemCount: stores.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final store = stores[index];
              return _FeaturedStoreCard(
                store: store,
                onTap: onStoreTap == null ? null : () => onStoreTap!(store),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FeaturedStoreCard extends StatelessWidget {
  final HomeFeaturedStore store;
  final VoidCallback? onTap;

  const _FeaturedStoreCard({required this.store, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      width: 116,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Ink(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
              child: Column(
                children: [
                  _StoreAvatar(store: store),
                  const SizedBox(height: 8),
                  Text(
                    store.name,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      color: colorScheme.onSurface,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StoreAvatar extends StatelessWidget {
  final HomeFeaturedStore store;

  const _StoreAvatar({required this.store});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.45),
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: _StoreImage(store: store),
    );
  }
}

class _StoreImage extends StatelessWidget {
  final HomeFeaturedStore store;

  const _StoreImage({required this.store});

  @override
  Widget build(BuildContext context) {
    if (store.imageAsset != null && store.imageAsset!.isNotEmpty) {
      return Image.asset(
        store.imageAsset!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const _StorePlaceholder(),
      );
    }

    if (store.imageUrl.isEmpty) return const _StorePlaceholder();

    return Image.network(
      store.imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => const _StorePlaceholder(),
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const _StorePlaceholder();
      },
    );
  }
}

class _StorePlaceholder extends StatelessWidget {
  const _StorePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(
        Icons.storefront_outlined,
        color: AppColors.primary,
        size: 28,
      ),
    );
  }
}

class HomeFeaturedStore {
  final String id;
  final String name;
  final String slug;
  final String description;
  final String imageUrl;
  final String? imageAsset;
  final String? targetUrl;

  const HomeFeaturedStore({
    required this.id,
    required this.name,
    this.slug = '',
    this.description = '',
    this.imageUrl = '',
    this.imageAsset,
    this.targetUrl,
  });

  factory HomeFeaturedStore.fromJson(Map<String, dynamic> json) {
    return HomeFeaturedStore(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? json['title'] ?? '').toString(),
      slug: (json['slug'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      imageUrl: (json['image_url'] ?? json['imageUrl'] ?? json['logo'] ?? '')
          .toString(),
      targetUrl: (json['target_url'] ?? json['targetUrl'] ?? json['url'])
          ?.toString(),
    );
  }

  static List<HomeFeaturedStore> listFromJson(List<dynamic> json) {
    return json
        .whereType<Map>()
        .map(
          (item) => HomeFeaturedStore.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }
}
