import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/app_router.dart';
import '../bloc/onboarding_bloc.dart';
import '../widgets/onboarding_state_content.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _syncPage(int index) {
    if (_pageController.hasClients &&
        _pageController.page?.round() != index) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<OnboardingBloc>()..add(const OnboardingStarted()),
      child: BlocConsumer<OnboardingBloc, OnboardingState>(
        listener: (context, state) {
          if (state is OnboardingDone) {
            context.go(AppRoutes.login);
          }

          if (state is OnboardingLoaded) {
            _syncPage(state.currentIndex);
          }
        },
        builder: (context, state) {
          return OnboardingStateContent(
            state: state,
            pageController: _pageController,
          );
        },
      ),
    );
  }
}
