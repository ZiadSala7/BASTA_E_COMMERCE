part of '../onboarding_bloc.dart';

class OnboardingPageChanged extends OnboardingEvent {
  final int pageIndex;
  const OnboardingPageChanged(this.pageIndex);
  @override
  List<Object> get props => [pageIndex];
}
