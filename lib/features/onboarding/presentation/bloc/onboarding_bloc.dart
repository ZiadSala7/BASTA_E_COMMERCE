import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/onboarding_page_entity.dart';
import '../../domain/usecases/get_onboarding_pages_usecase.dart';
import '../../domain/usecases/complete_onboarding_usecase.dart';

// ─── Events ───────────────────────────────────────────────────────────────────

part 'onboarding_bloc_parts/onboarding_event.dart';
part 'onboarding_bloc_parts/onboarding_started.dart';
part 'onboarding_bloc_parts/onboarding_page_changed.dart';
part 'onboarding_bloc_parts/onboarding_next_pressed.dart';
part 'onboarding_bloc_parts/onboarding_back_pressed.dart';
part 'onboarding_bloc_parts/onboarding_skip_pressed.dart';
part 'onboarding_bloc_parts/onboarding_completed.dart';
part 'onboarding_bloc_parts/onboarding_state.dart';
part 'onboarding_bloc_parts/onboarding_initial.dart';
part 'onboarding_bloc_parts/onboarding_loading.dart';
part 'onboarding_bloc_parts/onboarding_loaded.dart';
part 'onboarding_bloc_parts/onboarding_done.dart';
part 'onboarding_bloc_parts/onboarding_failure.dart';
part 'onboarding_bloc_parts/onboarding_bloc.dart';
