part of '../onboarding_bloc.dart';

class OnboardingFailure extends OnboardingState {
  final String message;
  const OnboardingFailure({required this.message});
  @override
  List<Object> get props => [message];
}

// ─── BLoC ─────────────────────────────────────────────────────────────────────
