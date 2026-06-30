part of '../cart_page.dart';

class _SwipeDeleteBackground extends StatelessWidget {
  const _SwipeDeleteBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 22),
      decoration: BoxDecoration(
        color: AppColors.badgeRed,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
    );
  }
}
