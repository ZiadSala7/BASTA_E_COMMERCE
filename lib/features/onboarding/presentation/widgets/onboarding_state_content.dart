import 'package:flutter/material.dart';

import '../bloc/onboarding_bloc.dart';
import 'onboarding_loaded.dart';

class OnboardingStateContent extends StatelessWidget {
  final OnboardingState state;
  final PageController pageController;

  const OnboardingStateContent({
    super.key,
    required this.state,
    required this.pageController,
  });

  @override
  Widget build(BuildContext context) {
    if (state is OnboardingLoading || state is OnboardingInitial) {
      return const _OnboardingLoadingView();
    }

    if (state is OnboardingFailure) {
      return _OnboardingFailureView(
        message: (state as OnboardingFailure).message,
      );
    }

    if (state is OnboardingLoaded) {
      return OnboardingLoadedView(
        state: state as OnboardingLoaded,
        pageController: pageController,
      );
    }

    return const SizedBox.shrink();
  }
}

class _OnboardingLoadingView extends StatelessWidget {
  const _OnboardingLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF4F4FF),
      body: Center(
        child: CircularProgressIndicator(color: Color(0xFF5B5BFF)),
      ),
    );
  }
}

class _OnboardingFailureView extends StatelessWidget {
  final String message;

  const _OnboardingFailureView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text(message)),
    );
  }
}
