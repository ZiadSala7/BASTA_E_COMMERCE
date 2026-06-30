part of '../onboarding_bloc.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final GetOnboardingPagesUseCase getOnboardingPages;
  final CompleteOnboardingUseCase completeOnboarding;

  OnboardingBloc({
    required this.getOnboardingPages,
    required this.completeOnboarding,
  }) : super(const OnboardingInitial()) {
    on<OnboardingStarted>(_onStarted);
    on<OnboardingPageChanged>(_onPageChanged);
    on<OnboardingNextPressed>(_onNext);
    on<OnboardingBackPressed>(_onBack);
    on<OnboardingSkipPressed>(_onSkip);
    on<OnboardingCompleted>(_onCompleted);
  }

  Future<void> _onStarted(
    OnboardingStarted event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(const OnboardingLoading());
    try {
      final pages = await getOnboardingPages();
      emit(OnboardingLoaded(pages: pages, currentIndex: 0));
    } catch (e) {
      emit(OnboardingFailure(message: e.toString()));
    }
  }

  void _onPageChanged(
    OnboardingPageChanged event,
    Emitter<OnboardingState> emit,
  ) {
    if (state is OnboardingLoaded) {
      emit((state as OnboardingLoaded).copyWith(currentIndex: event.pageIndex));
    }
  }

  void _onNext(OnboardingNextPressed event, Emitter<OnboardingState> emit) {
    if (state is! OnboardingLoaded) return;
    final s = state as OnboardingLoaded;
    if (s.isLast) {
      add(const OnboardingCompleted());
    } else {
      emit(s.copyWith(currentIndex: s.currentIndex + 1));
    }
  }

  void _onBack(OnboardingBackPressed event, Emitter<OnboardingState> emit) {
    if (state is! OnboardingLoaded) return;
    final s = state as OnboardingLoaded;
    if (!s.isFirst) {
      emit(s.copyWith(currentIndex: s.currentIndex - 1));
    }
  }

  Future<void> _onSkip(
    OnboardingSkipPressed event,
    Emitter<OnboardingState> emit,
  ) async {
    await completeOnboarding();
    emit(const OnboardingDone());
  }

  Future<void> _onCompleted(
    OnboardingCompleted event,
    Emitter<OnboardingState> emit,
  ) async {
    await completeOnboarding();
    emit(const OnboardingDone());
  }
}
