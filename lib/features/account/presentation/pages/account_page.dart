import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/extensions/app_localizations_x.dart';
import '../../../../core/utils/app_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/models/auth_verification_args.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../domain/entities/account_stats_entity.dart';
import '../cubits/account_cubit.dart';
import '../widgets/account_menu_sections.dart';
import '../widgets/account_stats_panel.dart';
import '../widgets/edit_profile_sheet.dart';
import '../widgets/logout_button.dart';
import '../widgets/profile_header.dart';

part 'account_page_parts/account_page.dart';
part 'account_page_parts/account_content.dart';
