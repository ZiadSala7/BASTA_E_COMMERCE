import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/extensions/app_localizations_x.dart';
import '../../../../core/managers/language_cubit.dart';
import '../../../../core/utils/app_router.dart';
import '../../../../l10n/app_localizations.dart';
import 'account_section.dart';

part 'account_menu_sections_parts/account_menu_section.dart';
part 'account_menu_sections_parts/account_support_section.dart';
part 'account_menu_sections_parts/account_settings_section.dart';
part 'account_menu_sections_parts/account_social_section.dart';
