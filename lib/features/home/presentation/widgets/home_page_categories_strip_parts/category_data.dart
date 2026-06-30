part of '../home_page_categories_strip.dart';

class _CategoryData {
  final String label;
  final String description;
  final IconData icon;
  final Color accent;
  final HomeCategoryEntity? category;

  const _CategoryData({
    required this.label,
    required this.description,
    required this.icon,
    required this.accent,
    this.category,
  });
}
