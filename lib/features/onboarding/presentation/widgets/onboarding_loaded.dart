import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/app_localizations.dart';
import '../bloc/onboarding_bloc.dart';
import 'onboarding_bottom_sheet.dart';
import 'onboarding_image_card.dart';

class OnboardingLoadedView extends StatelessWidget {
  final OnboardingLoaded state;
  final PageController pageController;

  const OnboardingLoadedView({
    super.key,
    required this.state,
    required this.pageController,
  });

  @override
  Widget build(BuildContext context) {
    final page = state.pages[state.currentIndex];
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4FF),
      body: Column(
        children: [
          Expanded(
            child: _OnboardingImagePager(
              state: state,
              pageController: pageController,
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.08),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: OnboardingBottomSheet(
              key: ValueKey(state.currentIndex),
              title: _resolveLocalizedText(localizations, page.title),
              subtitle: _resolveLocalizedText(localizations, page.subtitle),
              currentIndex: state.currentIndex,
              totalPages: state.pages.length,
              isFirst: state.isFirst,
              isLast: state.isLast,
            ),
          ),
        ],
      ),
    );
  }
}

String _resolveLocalizedText(AppLocalizations localizations, String key) {
  switch (key) {
    case 'onboardingTitle1':
      return localizations.onboardingTitle1;
    case 'onboardingSubtitle1':
      return localizations.onboardingSubtitle1;
    case 'onboardingTitle2':
      return localizations.onboardingTitle2;
    case 'onboardingSubtitle2':
      return localizations.onboardingSubtitle2;
    default:
      return key;
  }
}

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
          onPageChanged: (index) => context.read<OnboardingBloc>().add(
            OnboardingPageChanged(index),
          ),
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

class _GlowCircle extends StatelessWidget {
  final double size;
  final List<Color> colors;

  const _GlowCircle({
    required this.size,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: colors),
      ),
    );
  }
}
