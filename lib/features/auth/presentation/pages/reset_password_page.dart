import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/app_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubits/auth_cubit.dart';
import '../models/auth_verification_args.dart';
import '../utils/auth_validators.dart';
import '../widgets/auth_page_heading.dart';
import '../widgets/auth_page_scaffold.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_text_field.dart';

part 'reset_password_page_parts/reset_password_page.dart';
part 'reset_password_page_parts/reset_password_page_state.dart';
