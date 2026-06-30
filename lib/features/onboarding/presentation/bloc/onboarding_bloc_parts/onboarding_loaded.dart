part of '../onboarding_bloc.dart';

class OnboardingLoaded extends OnboardingState {
  final List<OnboardingPageEntity> pages;
  final int currentIndex;

  const OnboardingLoaded({required this.pages, required this.currentIndex});

  bool get isFirst => currentIndex == 0;
  bool get isLast => currentIndex == pages.length - 1;

  OnboardingLoaded copyWith({int? currentIndex}) => OnboardingLoaded(
    pages: pages,
    currentIndex: currentIndex ?? this.currentIndex,
  );

  @override
  List<Object> get props => [pages, currentIndex];
}
