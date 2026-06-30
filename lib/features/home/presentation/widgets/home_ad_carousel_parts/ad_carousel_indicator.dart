part of '../home_ad_carousel.dart';

class _AdCarouselIndicator extends StatelessWidget {
  final int count;
  final int activeIndex;

  const _AdCarouselIndicator({required this.count, required this.activeIndex});

  @override
  Widget build(BuildContext context) {
    if (count < 2) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var index = 0; index < count; index++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: index == activeIndex ? 46 : 10,
            height: 10,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: index == activeIndex
                  ? AppColors.primaryDark
                  : const Color(0xFFD5DCE3),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
      ],
    );
  }
}
