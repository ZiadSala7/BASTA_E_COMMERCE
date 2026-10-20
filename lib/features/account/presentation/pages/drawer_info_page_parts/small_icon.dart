part of '../drawer_info_page.dart';

class _SmallIcon extends StatelessWidget {
  const _SmallIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primaryFor(context);

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: primary, size: 21),
    );
  }
}
