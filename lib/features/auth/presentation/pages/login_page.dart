import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubits/auth_cubit.dart';
import '../models/auth_verification_args.dart';
import '../utils/auth_validators.dart';
import '../widgets/auth_brand_header.dart';
import '../widgets/auth_footer_link.dart';
import '../widgets/auth_page_heading.dart';
import '../widgets/auth_page_scaffold.dart';
import '../widgets/auth_primary_button.dart';
import '../widgets/auth_social_actions.dart';
import '../widgets/auth_text_field.dart';

part 'login_page_parts/login_page.dart';
part 'login_page_parts/login_page_state.dart';
part 'login_page_parts/remember_me_icon_button.dart';
