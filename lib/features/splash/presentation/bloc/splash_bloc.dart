import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/splash_entity.dart';
import '../../domain/usecases/get_initial_route_usecase.dart';

// ─── Events ──────────────────────────────────────────────────────────────────

abstract class SplashEvent extends Equatable {
  const SplashEvent();
  @override
  List<Object> get props => [];
}

class SplashStarted extends SplashEvent {
  const SplashStarted();
}

class SplashAnimationCompleted extends SplashEvent {
  const SplashAnimationCompleted();
}

// ─── States ──────────────────────────────────────────────────────────────────

abstract class SplashState extends Equatable {
  const SplashState();
  @override
  List<Object> get props => [];
}

class SplashInitial extends SplashState {
  const SplashInitial();
}

class SplashAnimating extends SplashState {
  const SplashAnimating();
}

class SplashNavigating extends SplashState {
  final String route;
  const SplashNavigating({required this.route});

  @override
  List<Object> get props => [route];
}

class SplashError extends SplashState {
  final String message;
  const SplashError({required this.message});

  @override
  List<Object> get props => [message];
}

// ─── BLoC ────────────────────────────────────────────────────────────────────

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final GetInitialRouteUseCase getInitialRoute;

  // Total splash animation duration before navigating
  static const _splashDuration = Duration(milliseconds: 3200);

  SplashBloc({required this.getInitialRoute}) : super(const SplashInitial()) {
    on<SplashStarted>(_onSplashStarted);
    on<SplashAnimationCompleted>(_onAnimationCompleted);
  }

  Future<void> _onSplashStarted(
    SplashStarted event,
    Emitter<SplashState> emit,
  ) async {
    emit(const SplashAnimating());

    final Future<SplashEntity> splashEntityFuture = getInitialRoute();
    await Future.delayed(_splashDuration);
    final SplashEntity entity = await splashEntityFuture;

    emit(SplashNavigating(route: entity.initialRoute));
  }

  Future<void> _onAnimationCompleted(
    SplashAnimationCompleted event,
    Emitter<SplashState> emit,
  ) async {
    // Can be used if you want manual control over navigation timing
  }
}
