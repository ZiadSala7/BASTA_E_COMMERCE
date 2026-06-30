// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/extensions/app_localizations_x.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_router.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/status/empty_state.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/app_notification_entity.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../../domain/services/notifications_controller.dart';

part 'notifications_page_parts/notification_filter.dart';
part 'notifications_page_parts/notifications_page.dart';
part 'notifications_page_parts/notifications_page_state.dart';
part 'notifications_page_parts/notifications_app_bar_title.dart';
part 'notifications_page_parts/notification_overview.dart';
part 'notifications_page_parts/overview_badge.dart';
part 'notifications_page_parts/read_state_tabs.dart';
part 'notifications_page_parts/read_state_tab.dart';
part 'notifications_page_parts/notifications_header.dart';
part 'notifications_page_parts/notifications_empty_state.dart';
part 'notifications_page_parts/notification_tile.dart';
part 'notifications_page_parts/status_badge.dart';
part 'notifications_page_parts/notification_type_pill.dart';
