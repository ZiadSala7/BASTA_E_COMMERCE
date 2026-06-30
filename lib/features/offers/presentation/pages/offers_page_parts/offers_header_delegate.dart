part of '../offers_page.dart';

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
