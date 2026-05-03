import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/onboarding_page_entity.dart';
import '../../domain/usecases/get_onboarding_pages_usecase.dart';
import '../../domain/usecases/complete_onboarding_usecase.dart';

// ─── Events ───────────────────────────────────────────────────────────────────

abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();
  @override
  List<Object> get props => [];
}

class OnboardingStarted extends OnboardingEvent {
  const OnboardingStarted();
}

class OnboardingPageChanged extends OnboardingEvent {
  final int pageIndex;
  const OnboardingPageChanged(this.pageIndex);
  @override
  List<Object> get props => [pageIndex];
}

class OnboardingNextPressed extends OnboardingEvent {
  const OnboardingNextPressed();
}

class OnboardingBackPressed extends OnboardingEvent {
  const OnboardingBackPressed();
}

class OnboardingSkipPressed extends OnboardingEvent {
  const OnboardingSkipPressed();
}

class OnboardingCompleted extends OnboardingEvent {
  const OnboardingCompleted();
}

// ─── States ───────────────────────────────────────────────────────────────────

abstract class OnboardingState extends Equatable {
  const OnboardingState();
  @override
  List<Object> get props => [];
}

class OnboardingInitial extends OnboardingState {
  const OnboardingInitial();
}

class OnboardingLoading extends OnboardingState {
  const OnboardingLoading();
}

class OnboardingLoaded extends OnboardingState {
  final List<OnboardingPageEntity> pages;
  final int currentIndex;

  const OnboardingLoaded({
    required this.pages,
    required this.currentIndex,
  });

  bool get isFirst => currentIndex == 0;
  bool get isLast  => currentIndex == pages.length - 1;

  OnboardingLoaded copyWith({int? currentIndex}) => OnboardingLoaded(
        pages:        pages,
        currentIndex: currentIndex ?? this.currentIndex,
      );

  @override
  List<Object> get props => [pages, currentIndex];
}

class OnboardingDone extends OnboardingState {
  const OnboardingDone();
}

class OnboardingFailure extends OnboardingState {
  final String message;
  const OnboardingFailure({required this.message});
  @override
  List<Object> get props => [message];
}

// ─── BLoC ─────────────────────────────────────────────────────────────────────

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
