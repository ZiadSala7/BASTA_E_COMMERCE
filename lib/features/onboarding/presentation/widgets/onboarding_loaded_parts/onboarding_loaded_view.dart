part of '../onboarding_loaded.dart';

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
