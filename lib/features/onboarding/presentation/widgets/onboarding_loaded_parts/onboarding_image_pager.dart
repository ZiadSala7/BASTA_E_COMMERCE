part of '../onboarding_loaded.dart';

class _OnboardingImagePager extends StatelessWidget {
  final OnboardingLoaded state;
  final PageController pageController;

  const _OnboardingImagePager({
    required this.state,
    required this.pageController,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Stack(
      children: [
        Positioned(
          top: -size.width * 0.25,
          right: -size.width * 0.25,
          child: _GlowCircle(
            size: size.width * 0.8,
            colors: const [Color(0x88F4B8C8), Color(0x00F4F4FF)],
          ),
        ),
        Positioned(
          bottom: -size.width * 0.15,
          left: -size.width * 0.15,
          child: _GlowCircle(
            size: size.width * 0.65,
            colors: const [Color(0x66C8B0F0), Color(0x00F4F4FF)],
          ),
        ),
        PageView.builder(
          controller: pageController,
          itemCount: state.pages.length,
          physics: const BouncingScrollPhysics(),
          onPageChanged: (index) =>
              context.read<OnboardingBloc>().add(OnboardingPageChanged(index)),
          itemBuilder: (_, index) => Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.paddingOf(context).top + 32,
              bottom: 20,
              left: 24,
              right: 24,
            ),
            child: Center(
              child: OnboardingImageCard(
                imagePath: state.pages[index].imagePath,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
