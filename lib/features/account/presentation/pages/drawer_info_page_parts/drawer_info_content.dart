part of '../drawer_info_page.dart';

class _DrawerInfoContent {
  const _DrawerInfoContent({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.sections,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<Widget> sections;
}
